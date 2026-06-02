using AutoMapper;
using Microsoft.AspNetCore.Mvc;
using GadgeonFinanceTracker.Models.Domain;
using GadgeonFinanceTracker.Models.DTO;
using GadgeonFinanceTracker.Repository;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;
using Asp.Versioning;

namespace GadgeonFinanceTracker.Controllers
{
    [Route("api/v{version:apiVersion}/[controller]")]
    [ApiController]
    [ApiVersion("1.0")]
    [ApiVersion("2.0")]
    public class TransactionsController : ControllerBase
    {
        private readonly ITransactionRepo transactionRepo;
        private readonly IMapper mapper;
        private readonly ILogger<TransactionsController> logger;

        public TransactionsController(ITransactionRepo transactionRepo, IMapper mapper, ILogger<TransactionsController> logger)
        {
            this.transactionRepo = transactionRepo;
            this.mapper = mapper;
            this.logger = logger;
        }
        [HttpGet]
        [MapToApiVersion("1.0")]
        [Authorize(Roles = "Reader")]
        public async Task<IActionResult> GetAll(
            [FromQuery] Guid? categoryId,
            [FromQuery] DateOnly? fromDate,
            [FromQuery] DateOnly? toDate,
            [FromQuery] string? sortBy,
            [FromQuery] bool? isAscending,
            [FromQuery] int pageNumber = 1,
            [FromQuery] int pageSize = 10)
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                var transactionsDomain = await transactionRepo.GetAllByUserIdAsync(userId, categoryId, fromDate, toDate, sortBy, isAscending, pageNumber, pageSize);
                var transactionsDTO = mapper.Map<List<TransactionRequestDTO>>(transactionsDomain);
                return Ok(transactionsDTO);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Error occurred while fetching transactions.");
                return StatusCode(500, "An error occurred while fetching transactions.");
            }
        }
        [HttpPost]
        [Authorize(Roles = "Reader")]
        public async Task<IActionResult> Create([FromBody] AddTransactionDTO transactionRequestDTO)
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                var transactionDomain = mapper.Map<Transaction>(transactionRequestDTO);
                transactionDomain.UserId = userId;
                var createdTransaction = await transactionRepo.CreateAsync(transactionDomain);
                var createdTransactionDTO = mapper.Map<TransactionRequestDTO>(createdTransaction);
                return CreatedAtAction(nameof(GetAll), new { id = createdTransaction.Id }, createdTransactionDTO);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Error occurred while creating a transaction.");
                return StatusCode(500, "An error occurred while creating the transaction.");
            }
        }
        [HttpPut("{id:Guid}")]
        [Authorize(Roles = "Reader")]
        public async Task<IActionResult> Update([FromRoute] Guid id, [FromBody] UpdateTransactionDTO transactionRequestDTO)
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

                // map first
                var transactionDomain = mapper.Map<Transaction>(transactionRequestDTO);

                // then update with ownership check
                var updatedTransaction = await transactionRepo.UpdateAsync(id, userId, transactionDomain);
                if (updatedTransaction == null)
                    return NotFound("Transaction not found or you don't have permission to update it.");

                var updatedTransactionDTO = mapper.Map<TransactionRequestDTO>(updatedTransaction);
                return Ok(updatedTransactionDTO);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Error occurred while updating the transaction.");
                return StatusCode(500, "An error occurred while updating the transaction.");
            }
        }

        [HttpDelete("{id:Guid}")]
        [Authorize(Roles = "Reader")]
        public async Task<IActionResult> Delete([FromRoute] Guid id)
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                var deletedTransaction = await transactionRepo.DeleteAsync(id, userId);
                if (deletedTransaction == null)
                    return NotFound("Transaction not found or you don't have permission to delete it.");
                var deletedTransactionDTO = mapper.Map<TransactionRequestDTO>(deletedTransaction);
                return Ok(deletedTransactionDTO);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Error occurred while deleting the transaction.");
                return StatusCode(500, "An error occurred while deleting the transaction.");
            }
        }
        [HttpGet]
        [MapToApiVersion("2.0")]
        [Authorize(Roles = "Reader")]
        public async Task<IActionResult> GetAllV2(
        [FromQuery] Guid? categoryId,
        [FromQuery] DateOnly? fromDate,
        [FromQuery] DateOnly? toDate,
        [FromQuery] string? sortBy,
        [FromQuery] bool? isAscending,
        [FromQuery] int pageNumber = 1,
        [FromQuery] int pageSize = 10)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var walkDomainModel = await transactionRepo.GetAllByUserIdAsync(
                userId, categoryId, fromDate, toDate, sortBy, isAscending, pageNumber, pageSize);

            // map to a v2 DTO that includes category type
            var transactionsDto = walkDomainModel.Select(t => new
            {
                t.Id,
                t.Amount,
                t.Description,
                t.Date,
                t.UserId,
                CategoryId = t.CategoryId,
                CategoryName = t.Category?.Name,
                CategoryType = t.Category?.Type.ToString() // ← new field in v2
            });

            return Ok(transactionsDto);
        }
    }
}