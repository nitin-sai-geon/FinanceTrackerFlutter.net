using Microsoft.EntityFrameworkCore;
using GadgeonFinanceTracker.Models.Domain;
namespace GadgeonFinanceTracker.Data
{
    public class FinanceTrackerDBContext : DbContext
    {

        public FinanceTrackerDBContext(DbContextOptions<FinanceTrackerDBContext> dbcontextoptions) : base(dbcontextoptions)
        {

        }

        public DbSet<Transaction> Transactions { get; set; }
        public DbSet<Category> Categories { get; set; }

        public DbSet<TransactionAttachment> TransactionAttachments { get; set; }


        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<Transaction>()
               .Property(t => t.Amount)
               .HasPrecision(18, 2);

            modelBuilder.Entity<Transaction>()
            .HasOne(t => t.Attachment)
            .WithOne(a => a.Transaction)
            .HasForeignKey<TransactionAttachment>(a => a.TransactionId);

            var categories = new List<Category>



    {
        // keep existing 4
        new Category { Id = Guid.Parse("a1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1"), Name = "Salary", Type = CategoryType.Income },
        new Category { Id = Guid.Parse("b2b2b2b2-b2b2-b2b2-b2b2-b2b2b2b2b2b2"), Name = "Food", Type = CategoryType.Expense },
        new Category { Id = Guid.Parse("c3c3c3c3-c3c3-c3c3-c3c3-c3c3c3c3c3c3"), Name = "Transport", Type = CategoryType.Expense },
        new Category { Id = Guid.Parse("d4d4d4d4-d4d4-d4d4-d4d4-d4d4d4d4d4d4"), Name = "Entertainment", Type = CategoryType.Expense },

        // add new ones with unique GUIDs
        new Category { Id = Guid.Parse("e5e5e5e5-e5e5-e5e5-e5e5-e5e5e5e5e5e5"), Name = "Freelance", Type = CategoryType.Income },
        new Category { Id = Guid.Parse("f6f6f6f6-f6f6-f6f6-f6f6-f6f6f6f6f6f6"), Name = "Investment", Type = CategoryType.Income },
        new Category { Id = Guid.Parse("a7a7a7a7-a7a7-a7a7-a7a7-a7a7a7a7a7a7"), Name = "Shopping", Type = CategoryType.Expense },
        new Category { Id = Guid.Parse("b8b8b8b8-b8b8-b8b8-b8b8-b8b8b8b8b8b8"), Name = "Health & Medical", Type = CategoryType.Expense },
        new Category { Id = Guid.Parse("c9c9c9c9-c9c9-c9c9-c9c9-c9c9c9c9c9c9"), Name = "Rent & Housing", Type = CategoryType.Expense },
        new Category { Id = Guid.Parse("d0d0d0d0-d0d0-d0d0-d0d0-d0d0d0d0d0d0"), Name = "Utilities", Type = CategoryType.Expense },
        new Category { Id = Guid.Parse("e1e1e1e1-e1e1-e1e1-e1e1-e1e1e1e1e1e1"), Name = "Education", Type = CategoryType.Expense },
        new Category { Id = Guid.Parse("f2f2f2f2-f2f2-f2f2-f2f2-f2f2f2f2f2f2"), Name = "Travel", Type = CategoryType.Expense },
        new Category { Id = Guid.Parse("a3a3a3a3-a3a3-a3a3-a3a3-a3a3a3a3a3a3"), Name = "Fuel", Type = CategoryType.Expense },
    };

            modelBuilder.Entity<Category>().HasData(categories);
        }
    }
}
