namespace GadgeonFinanceTracker.Models.Domain
{
    public enum CategoryType
    {
        Income,
        Expense
    }

    public class Category
    {
        public Guid Id { get; set; }
        public string Name { get; set; }
        public CategoryType Type { get; set; }

        public string? UserId { get; set; }

        // Navigation property
        public List<Transaction> Transactions { get; set; }


    }
}