using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace LibraryManagementSystem.Models
{
    public enum Location
    {
        Home,
        Work,
        Loaned,
        Unknown
    }

    public class Book
    {
        public int Id { get; set; }

        [Required]
        [StringLength(200)]
        public string Title { get; set; } = string.Empty;

        [StringLength(200)]
        public string? Author { get; set; }

        [StringLength(30)]
        public string? ISBN { get; set; }

        public Location Location { get; set; } = Location.Home;

        [StringLength(1000)]
        public string? Description { get; set; }

        [NotMapped]
        public string? Tags { get; set; }
    }
}
