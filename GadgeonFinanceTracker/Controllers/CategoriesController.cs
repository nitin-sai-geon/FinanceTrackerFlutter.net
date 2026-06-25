using AutoMapper;
using GadgeonFinanceTracker.Data;
using GadgeonFinanceTracker.Models.Domain;
using GadgeonFinanceTracker.Models.DTO;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace GadgeonFinanceTracker.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CategoriesController : ControllerBase
    {
        private readonly FinanceTrackerDBContext dbContext;
        private readonly IMapper mapper;
        private readonly ILogger<CategoriesController> logger;

        public CategoriesController(FinanceTrackerDBContext dbContext, IMapper mapper,
            ILogger<CategoriesController> logger)
        {
            this.dbContext = dbContext;
            this.mapper = mapper;
            this.logger = logger;
        }

        [HttpGet]
        [Authorize(Roles = "Reader,Writer")]
        public async Task<IActionResult> GetAll()
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                logger.LogInformation("Fetching categories for user {UserId}", userId);

                var categories = await dbContext.Categories
                    .Where(c => c.UserId == null || c.UserId == userId)
                    .ToListAsync();

                logger.LogInformation("Returned {Count} categories for user {UserId}",
                    categories.Count, userId);

                var categoriesDto = mapper.Map<List<CategoryResponseDTO>>(categories);
                return Ok(categoriesDto);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Error occurred while fetching categories.");
                return StatusCode(500, "An error occurred while fetching categories.");
            }
        }

        [HttpPost]
        [Authorize(Roles = "Reader,Writer")]
        public async Task<IActionResult> AddNew([FromBody] CreateNewCategoryDTO dto)
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                logger.LogInformation("Creating category '{Name}' for user {UserId}",
                    dto.Name, userId);

                var category = new Category
                {
                    Id = Guid.NewGuid(),
                    Name = dto.Name,
                    Type = dto.Type,
                    UserId = userId
                };

                await dbContext.Categories.AddAsync(category);
                await dbContext.SaveChangesAsync();

                logger.LogInformation("Category '{Name}' created with Id {Id}",
                    category.Name, category.Id);

                var categoryDto = mapper.Map<CategoryResponseDTO>(category);
                return CreatedAtAction(nameof(GetAll), categoryDto);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Error occurred while creating category.");
                return StatusCode(500, "An error occurred while creating the category.");
            }
        }
    }
}