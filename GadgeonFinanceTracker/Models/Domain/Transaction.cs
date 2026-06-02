namespace GadgeonFinanceTracker.Models.Domain
{
    public class Transaction
    {
        public Guid Id { get; set; }
        public decimal Amount { get; set; }
        public string Description { get; set; }
        public DateOnly Date { get; set; }
        public Guid CategoryId { get; set; }
        public string UserId { get; set; }

        // Navigation properties
        public Category Category { get; set; }
    }
}