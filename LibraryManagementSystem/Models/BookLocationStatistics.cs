namespace LibraryManagementSystem.Models
{
    public class BookLocationStatistics
    {
        public Location Location { get; set; }
        public int Count { get; set; }
        public string LocationName => Location.ToString();
    }

    public class HomeViewModel
    {
        public List<BookLocationStatistics> LocationStatistics { get; set; } = new();
        public int TotalBooks { get; set; }
    }
}
