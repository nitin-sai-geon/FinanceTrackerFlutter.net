using AutoMapper;
using GadgeonFinanceTracker.Data;
using GadgeonFinanceTracker.Models.DTO;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace GadgeonFinanceTracker.Controllers
{
    [Route("api/[controller]")]  
    [ApiController]               
    public class CategoriesController : ControllerBase    
    {
        private readonly FinanceTrackerDBContext dbContext;   
        private readonly IMapper mapper;                      

        public CategoriesController(FinanceTrackerDBContext dbContext, IMapper mapper)    
        {
            this.dbContext = dbContext;
            this.mapper = mapper;
        }

        [HttpGet]
        [Authorize(Roles = "Reader,Writer")]
        public async Task<IActionResult> GetAll()
        {
            var categories = await dbContext.Categories.ToListAsync();
            var categoriesDto = mapper.Map<List<CategoryResponseDTO>>(categories);
            return Ok(categoriesDto);
        }
    }
}