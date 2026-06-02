using Microsoft.EntityFrameworkCore;
using GadgeonFinanceTracker.Data;
using GadgeonFinanceTracker.Models.Domain;

namespace GadgeonFinanceTracker.Repository
{
    public class SQLTransactionRepo : ITransactionRepo
    {
        private readonly FinanceTrackerDBContext dbContext;

        public SQLTransactionRepo(FinanceTrackerDBContext dbContext)
        {
            this.dbContext = dbContext;
        }

        public async Task<Transaction> CreateAsync(Transaction transaction)
        {
            dbContext.Transactions.Add(transaction);
            await dbContext.SaveChangesAsync();
            return transaction;
        }

        public async Task<Transaction?> DeleteAsync(Guid id, string userId)
        {
            var transaction = await dbContext.Transactions.FirstOrDefaultAsync(t => t.Id == id && t.UserId == userId);
            if (transaction == null)
                return null;
            dbContext.Transactions.Remove(transaction);
            await dbContext.SaveChangesAsync();
            return transaction;
        }

        public async Task<List<Transaction>> GetAllByUserIdAsync(
            string userId,
            Guid? categoryId = null,
            DateOnly? fromDate = null,
            DateOnly? toDate = null,
            string? sortBy = null,
            bool? isAscending = true,
            int pageNumber = 1,
            int pageSize = 10)
        {
            var transactions = dbContext.Transactions
                .Include(t => t.Category)
                .Where(t => t.UserId == userId)
                .AsQueryable();

            // filter by category
            if (categoryId.HasValue)
                transactions = transactions.Where(t => t.CategoryId == categoryId.Value);

            // filter by date range
            if (fromDate.HasValue)
                transactions = transactions.Where(t => t.Date >= fromDate.Value);

            if (toDate.HasValue)
                transactions = transactions.Where(t => t.Date <= toDate.Value);

            // sorting
            if (!string.IsNullOrEmpty(sortBy))
            {
                if (sortBy.Equals("Amount", StringComparison.OrdinalIgnoreCase))
                    transactions = isAscending == true ? transactions.OrderBy(t => t.Amount) : transactions.OrderByDescending(t => t.Amount);
                else if (sortBy.Equals("Date", StringComparison.OrdinalIgnoreCase))
                    transactions = isAscending == true ? transactions.OrderBy(t => t.Date) : transactions.OrderByDescending(t => t.Date);
            }

            // pagination
            transactions = transactions.Skip((pageNumber - 1) * pageSize).Take(pageSize);

            return await transactions.ToListAsync();
        }

        public async Task<Transaction?> UpdateAsync(Guid id, string userId, Transaction transaction)
        {
            var existing = await dbContext.Transactions
                .FirstOrDefaultAsync(t => t.Id == id && t.UserId == userId);
            if (existing == null) return null;

            existing.Amount = transaction.Amount;
            existing.Description = transaction.Description;
            existing.Date = transaction.Date;
            existing.CategoryId = transaction.CategoryId;

            await dbContext.SaveChangesAsync();
            return existing;
        }
    }
}