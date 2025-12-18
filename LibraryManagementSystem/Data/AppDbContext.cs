using LibraryManagementSystem.Models;
using Microsoft.EntityFrameworkCore;

namespace LibraryManagementSystem.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<Book> Books => Set<Book>();

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Store enum as string for readability
            modelBuilder.Entity<Book>().Property(b => b.Location).HasConversion<string>();

            // Seed some sample data
            modelBuilder.Entity<Book>().HasData(
                new Book { Id = 1, Title = "The Hobbit", Author = "J.R.R. Tolkien", ISBN = "978-0547928227", Location = Location.Home, Description = "Classic fantasy novel." },
                new Book { Id = 2, Title = "Clean Code", Author = "Robert C. Martin", ISBN = "978-0132350884", Location = Location.Work, Description = "A handbook of agile software craftsmanship." },
                new Book { Id = 3, Title = "The Pragmatic Programmer", Author = "Andrew Hunt", ISBN = "978-0201616224", Location = Location.Home, Description = "Tips for pragmatic developers." }
            );
        }

        public static void SeedData(AppDbContext context)
        {
            // If using EnsureCreated(), data seeded above via HasData won't apply. We'll ensure minimal seed here for first-run.
            if (!context.Books.Any())
            {
                context.Books.AddRange(
                    new Book { Title = "The Hobbit", Author = "J.R.R. Tolkien", ISBN = "978-0547928227", Location = Location.Home, Description = "Classic fantasy novel." },
                    new Book { Title = "Clean Code", Author = "Robert C. Martin", ISBN = "978-0132350884", Location = Location.Work, Description = "A handbook of agile software craftsmanship." },
                    new Book { Title = "The Pragmatic Programmer", Author = "Andrew Hunt", ISBN = "978-0201616224", Location = Location.Home, Description = "Tips for pragmatic developers." }
                );
                context.SaveChanges();
            }
        }
    }
}
