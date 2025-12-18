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
    }
}
