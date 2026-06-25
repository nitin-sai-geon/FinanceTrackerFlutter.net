using AutoMapper;
using Microsoft.AspNetCore.Mvc;
using GadgeonFinanceTracker.Models.Domain;
using GadgeonFinanceTracker.Models.DTO;
using GadgeonFinanceTracker.Repository;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;
using Asp.Versioning;
using Microsoft.EntityFrameworkCore;
using GadgeonFinanceTracker.Data;

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
        private readonly FinanceTrackerDBContext dbContext;

        public TransactionsController(ITransactionRepo transactionRepo, IMapper mapper, ILogger<TransactionsController> logger,FinanceTrackerDBContext dBContext)
        {
            this.transactionRepo = transactionRepo;
            this.mapper = mapper;
            this.logger = logger;
            this.dbContext= dBContext;
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
                logger.LogInformation("Fetching transactions for user {UserId} (page {Page}, size {Size})", userId, pageNumber, pageSize);
                var transactionsDomain = await transactionRepo.GetAllByUserIdAsync(userId, categoryId, fromDate, toDate, sortBy, isAscending, pageNumber, pageSize);
                logger.LogInformation("Returned {Count} transactions for user {UserId}", transactionsDomain.Count, userId);
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
                logger.LogInformation("Creating transaction for user {UserId}: {Description} {Amount}", userId, transactionRequestDTO.Description, transactionRequestDTO.Amount);
                var transactionDomain = mapper.Map<Transaction>(transactionRequestDTO);
                transactionDomain.UserId = userId;
                var createdTransaction = await transactionRepo.CreateAsync(transactionDomain);
                logger.LogInformation("Transaction created with Id {Id} for user {UserId}", createdTransaction.Id, userId);
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
                logger.LogInformation("Updating transaction {Id} for user {UserId}", id, userId);
                var transactionDomain = mapper.Map<Transaction>(transactionRequestDTO);
                var updatedTransaction = await transactionRepo.UpdateAsync(id, userId, transactionDomain);
                if (updatedTransaction == null)
                {
                    logger.LogWarning("Transaction {Id} not found or not owned by user {UserId}", id, userId);
                    return NotFound("Transaction not found or you don't have permission to update it.");
                }
                logger.LogInformation("Transaction {Id} updated for user {UserId}", id, userId);
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
                logger.LogInformation("Deleting transaction {Id} for user {UserId}", id, userId);
                var deletedTransaction = await transactionRepo.DeleteAsync(id, userId);
                if (deletedTransaction == null)
                {
                    logger.LogWarning("Transaction {Id} not found or not owned by user {UserId}", id, userId);
                    return NotFound("Transaction not found or you don't have permission to delete it.");
                }
                logger.LogInformation("Transaction {Id} deleted for user {UserId}", id, userId);
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
            logger.LogInformation("Fetching transactions v2 for user {UserId} (page {Page}, size {Size})", userId, pageNumber, pageSize);
            var walkDomainModel = await transactionRepo.GetAllByUserIdAsync(
                userId, categoryId, fromDate, toDate, sortBy, isAscending, pageNumber, pageSize);

            var transactionsDto = walkDomainModel.Select(t => new
            {
                t.Id,
                t.Amount,
                t.Description,
                t.Date,
                t.UserId,
                CategoryId = t.CategoryId,
                CategoryName = t.Category?.Name,
                CategoryType = t.Category?.Type.ToString()
            });

            return Ok(transactionsDto);
        }

        [HttpPost("{id}/attachment")]
        [Authorize(Roles = "Reader")]
        public async Task<IActionResult> UploadAttachment([FromRoute] Guid id, IFormFile file)
        {
            var allowedTypes = new[] { "image/png", "image/jpeg", "image/jpg", "image/svg+xml" };
            if (!allowedTypes.Contains(file.ContentType))
            {
                logger.LogWarning("Rejected attachment upload for transaction {Id}: invalid type {ContentType}", id, file.ContentType);
                return BadRequest("Only PNG or SVG images are allowed.");
            }

            logger.LogInformation("Uploading attachment for transaction {Id}: {FileName} ({Size} bytes)", id, file.FileName, file.Length);
            var filename = $"{Guid.NewGuid()}_{file.FileName}";
            var physicalPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", "transactions", filename);
            var relativePath = Path.Combine("uploads", "transactions", filename);

            Directory.CreateDirectory(Path.GetDirectoryName(physicalPath)!);

            using (var stream = new FileStream(physicalPath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            var attachment = new TransactionAttachment
            {
                Id = Guid.NewGuid(),
                TransactionId = id,
                FileName = file.FileName,
                FilePath = relativePath,
                ContentType = file.ContentType,
                FileSizeBytes = file.Length
            };

            await dbContext.TransactionAttachments.AddAsync(attachment);
            await dbContext.SaveChangesAsync();

            logger.LogInformation("Attachment saved for transaction {Id} at {Path}", id, relativePath);
            return Ok(new { attachmentPath = relativePath });
        }

        }
    }
