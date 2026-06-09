using GadgeonFinanceTracker.Models.Domain;

namespace GadgeonFinanceTracker.Repository
{
    public interface ITransactionRepo
    {
        Task<List<Transaction>> GetAllByUserIdAsync(
            string userId,
            Guid? categoryId = null,
            DateOnly? fromDate = null,
            DateOnly? toDate = null,
            string? sortBy = null,
            bool? isAscending = true,
            int pageNumber = 1,
            int pageSize = 10);

        Task<Transaction> CreateAsync(Transaction transaction);
        Task<Transaction?> UpdateAsync(Guid id, string userId, Transaction transaction);
        Task<Transaction?> DeleteAsync(Guid id, string userId);
    }
}