using Microsoft.AspNetCore.Mvc;
using LibraryManagementSystem.Data;
using LibraryManagementSystem.Models;
using Microsoft.EntityFrameworkCore;

namespace LibraryManagementSystem.Controllers
{
    public class HomeController : Controller
    {
        private readonly AppDbContext _context;

        public HomeController(AppDbContext context)
        {
            _context = context;
        }

        // GET: /
        public async Task<IActionResult> Index()
        {
            var viewModel = new HomeViewModel();

            // Get statistics for each location
            var locationStats = await _context.Books
                .GroupBy(b => b.Location)
                .Select(g => new BookLocationStatistics
                {
                    Location = g.Key,
                    Count = g.Count()
                })
                .OrderByDescending(s => s.Count)
                .ToListAsync();

            viewModel.LocationStatistics = locationStats;
            viewModel.TotalBooks = await _context.Books.CountAsync();

            return View(viewModel);
        }
    }
}
