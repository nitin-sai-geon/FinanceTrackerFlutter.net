using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.AspNetCore.Identity;
using GadgeonFinanceTracker.Models.Domain;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using GadgeonFinanceTracker.Models.Domain;

namespace GadgeonFinanceTracker.Data
{
    public class FinanceTrackerAuthDbContext : IdentityDbContext<ApplicationUser>
    {
        public FinanceTrackerAuthDbContext(DbContextOptions<FinanceTrackerAuthDbContext> options) : base(options)
        {
        }

        protected override void OnModelCreating(ModelBuilder builder)
        {
            base.OnModelCreating(builder);

            var readerRoleId = "b11c970e-c283-4f89-a85c-a92730b467c1";
            var writerRoleId = "3839fb3c-de84-4641-8375-a75671bbcdf1";

            var roles = new List<IdentityRole>
            {
                new IdentityRole
                {
                    Id = readerRoleId,
                    ConcurrencyStamp = readerRoleId,
                    Name = "Reader",
                    NormalizedName = "READER"
                },
                new IdentityRole
                {
                    Id = writerRoleId,
                    ConcurrencyStamp = writerRoleId,
                    Name = "Writer",
                    NormalizedName = "WRITER"
                }
            };

            builder.Entity<IdentityRole>().HasData(roles);
        }
    }
}