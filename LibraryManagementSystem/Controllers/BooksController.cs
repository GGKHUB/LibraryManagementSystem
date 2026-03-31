using LibraryManagementSystem.Data;
using LibraryManagementSystem.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace LibraryManagementSystem.Controllers
{
    public class BooksController : Controller
    {
        private readonly AppDbContext _context;
        private readonly ILogger<BooksController> _logger;

        public BooksController(AppDbContext context, ILogger<BooksController> logger)
        {
            _context = context;
            _logger = logger;
        }

        // GET: Books
        public async Task<IActionResult> Index(string? searchTitle, string? searchIsbn, Location? searchLocation)
        {
            var query = _context.Books.AsQueryable();

            if (!string.IsNullOrWhiteSpace(searchTitle))
                query = query.Where(b => b.Title.Contains(searchTitle));

            if (!string.IsNullOrWhiteSpace(searchIsbn))
                query = query.Where(b => b.ISBN != null && b.ISBN.Contains(searchIsbn));

            if (searchLocation != null)
                query = query.Where(b => b.Location == searchLocation);

            var model = await query.OrderBy(b => b.Title).ToListAsync();
            ViewData["SearchTitle"] = searchTitle;
            ViewData["SearchIsbn"] = searchIsbn;
            ViewData["SearchLocation"] = searchLocation?.ToString() ?? string.Empty;
            return View(model);
        }

        // GET: Books/Details/5
        public async Task<IActionResult> Details(int? id)
        {
            if (id == null) return NotFound();
            var book = await _context.Books.FirstOrDefaultAsync(m => m.Id == id);
            if (book == null) return NotFound();
            return View(book);
        }

        // GET: Books/Create
        public IActionResult Create()
        {
            return View();
        }

        // POST: Books/Create
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create([Bind("Title,Author,ISBN,Location,Description")] Book book)
        {
            if (!ModelState.IsValid)
            {
                _logger.LogWarning("Create: invalid model state: {Errors}", string.Join("; ", ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage)));
                return View(book);
            }
                
            try
            {
                _context.Add(book);
                await _context.SaveChangesAsync();
                _logger.LogInformation("Book created: {Title} (Id: {Id})", book.Title, book.Id);
                return RedirectToAction(nameof(Index));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating book");
                ModelState.AddModelError(string.Empty, "An error occurred while saving the book. Please try again.");
                return View(book);
            }
        }

        // GET: Books/Edit/5
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null) return NotFound();
            var book = await _context.Books.FindAsync(id);
            if (book == null) return NotFound();
            return View(book);
        }

        // POST: Books/Edit/5
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, [Bind("Id,Title,Author,ISBN,Location,Description")] Book book)
        {
            if (id != book.Id) return NotFound();
            if (!ModelState.IsValid)
            {
                _logger.LogWarning("Edit: invalid model state for Id {Id}: {Errors}", id, string.Join("; ", ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage)));
                return View(book);
            }

            try
            {
                _context.Update(book);
                await _context.SaveChangesAsync();
                _logger.LogInformation("Book updated: {Title} (Id: {Id})", book.Title, book.Id);
            }
            catch (DbUpdateConcurrencyException ex)
            {
                _logger.LogError(ex, "Concurrency error updating book Id {Id}", book.Id);
                if (!_context.Books.Any(e => e.Id == book.Id)) return NotFound();
                ModelState.AddModelError(string.Empty, "Could not save the book due to a concurrency issue. Please try again.");
                return View(book);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating book Id {Id}", book.Id);
                ModelState.AddModelError(string.Empty, "An error occurred while saving the book. Please try again.");
                return View(book);
            }

            return RedirectToAction(nameof(Index));
        }

        // GET: Books/Delete/5
        public async Task<IActionResult> Delete(int? id)
        {
            if (id == null) return NotFound();
            var book = await _context.Books.FirstOrDefaultAsync(m => m.Id == id);
            if (book == null) return NotFound();
            return View(book);
        }

                // POST: Books/Delete/5
                [HttpPost, ActionName("Delete")]
                [ValidateAntiForgeryToken]
                public async Task<IActionResult> DeleteConfirmed(int id)
                {
                    var book = await _context.Books.FindAsync(id);
                    if (book != null)
                    {
                        _context.Books.Remove(book);
                        await _context.SaveChangesAsync();
                    }
                    return RedirectToAction(nameof(Index));
                }

                // GET: Books/ImportCsv
                public IActionResult ImportCsv()
                {
                    return View();
                }

                // POST: Books/ImportCsv
                [HttpPost]
                [ValidateAntiForgeryToken]
                public async Task<IActionResult> ImportCsv(IFormFile? csvFile)
                {
                    if (csvFile == null || csvFile.Length == 0)
                    {
                        ModelState.AddModelError(string.Empty, "Please select a CSV file to upload.");
                        return View();
                    }

                    if (!csvFile.FileName.EndsWith(".csv", StringComparison.OrdinalIgnoreCase))
                    {
                        ModelState.AddModelError(string.Empty, "Only .csv files are allowed.");
                        return View();
                    }

                    var imported = 0;
                    var errors = new List<string>();

                    using var reader = new StreamReader(csvFile.OpenReadStream());

                    // Read header row
                    var headerLine = await reader.ReadLineAsync();
                    if (string.IsNullOrWhiteSpace(headerLine))
                    {
                        ModelState.AddModelError(string.Empty, "The CSV file is empty.");
                        return View();
                    }

                    var headers = ParseCsvLine(headerLine)
                        .Select(h => h.Trim().ToLowerInvariant())
                        .ToArray();

                    var titleIdx = Array.IndexOf(headers, "title");
                    if (titleIdx < 0)
                    {
                        ModelState.AddModelError(string.Empty, "CSV must contain a 'Title' column header.");
                        return View();
                    }

                    var authorIdx = Array.IndexOf(headers, "author");
                    var isbnIdx = Array.IndexOf(headers, "isbn");
                    var locationIdx = Array.IndexOf(headers, "location");
                    var descriptionIdx = Array.IndexOf(headers, "description");

                    var lineNumber = 1;
                    while (!reader.EndOfStream)
                    {
                        lineNumber++;
                        var line = await reader.ReadLineAsync();
                        if (string.IsNullOrWhiteSpace(line)) continue;

                        var fields = ParseCsvLine(line);

                        var title = GetField(fields, titleIdx);
                        if (string.IsNullOrWhiteSpace(title))
                        {
                            errors.Add($"Row {lineNumber}: Title is required. Skipped.");
                            continue;
                        }

                        var location = Location.Home;
                        var locationStr = GetField(fields, locationIdx);
                        if (!string.IsNullOrWhiteSpace(locationStr))
                        {
                            if (!Enum.TryParse<Location>(locationStr, ignoreCase: true, out location))
                            {
                                errors.Add($"Row {lineNumber}: Invalid location '{locationStr}'. Defaulting to Home.");
                                location = Location.Home;
                            }
                        }

                        var book = new Book
                        {
                            Title = title.Length > 200 ? title[..200] : title,
                            Author = Truncate(GetField(fields, authorIdx), 200),
                            ISBN = Truncate(GetField(fields, isbnIdx), 30),
                            Location = location,
                            Description = Truncate(GetField(fields, descriptionIdx), 1000)
                        };

                        _context.Books.Add(book);
                        imported++;
                    }

                    if (imported > 0)
                    {
                        await _context.SaveChangesAsync();
                        _logger.LogInformation("CSV import: {Count} books imported.", imported);
                    }

                    ViewData["ImportedCount"] = imported;
                    ViewData["Errors"] = errors;
                    return View();
                }

                private static string? GetField(string[] fields, int index)
                {
                    if (index < 0 || index >= fields.Length) return null;
                    var value = fields[index].Trim();
                    return string.IsNullOrEmpty(value) ? null : value;
                }

                private static string? Truncate(string? value, int maxLength)
                {
                    if (value == null) return null;
                    return value.Length > maxLength ? value[..maxLength] : value;
                }

                private static string[] ParseCsvLine(string line)
                {
                    var fields = new List<string>();
                    var current = "";
                    var inQuotes = false;

                    for (int i = 0; i < line.Length; i++)
                    {
                        var c = line[i];

                        if (inQuotes)
                        {
                            if (c == '"')
                            {
                                if (i + 1 < line.Length && line[i + 1] == '"')
                                {
                                    current += '"';
                                    i++;
                                }
                                else
                                {
                                    inQuotes = false;
                                }
                            }
                            else
                            {
                                current += c;
                            }
                        }
                        else
                        {
                            if (c == '"')
                            {
                                inQuotes = true;
                            }
                            else if (c == ',')
                            {
                                fields.Add(current);
                                current = "";
                            }
                            else
                            {
                                current += c;
                            }
                        }
                    }

                    fields.Add(current);
                    return fields.ToArray();
                }
            }
        }
