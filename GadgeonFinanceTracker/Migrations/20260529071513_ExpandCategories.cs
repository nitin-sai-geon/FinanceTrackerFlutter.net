using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace GadgeonFinanceTracker.Migrations
{
    /// <inheritdoc />
    public partial class ExpandCategories : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "Categories",
                columns: new[] { "Id", "Name", "Type" },
                values: new object[,]
                {
                    { new Guid("a3a3a3a3-a3a3-a3a3-a3a3-a3a3a3a3a3a3"), "Fuel", 1 },
                    { new Guid("a7a7a7a7-a7a7-a7a7-a7a7-a7a7a7a7a7a7"), "Shopping", 1 },
                    { new Guid("b8b8b8b8-b8b8-b8b8-b8b8-b8b8b8b8b8b8"), "Health & Medical", 1 },
                    { new Guid("c9c9c9c9-c9c9-c9c9-c9c9-c9c9c9c9c9c9"), "Rent & Housing", 1 },
                    { new Guid("d0d0d0d0-d0d0-d0d0-d0d0-d0d0d0d0d0d0"), "Utilities", 1 },
                    { new Guid("e1e1e1e1-e1e1-e1e1-e1e1-e1e1e1e1e1e1"), "Education", 1 },
                    { new Guid("e5e5e5e5-e5e5-e5e5-e5e5-e5e5e5e5e5e5"), "Freelance", 0 },
                    { new Guid("f2f2f2f2-f2f2-f2f2-f2f2-f2f2f2f2f2f2"), "Travel", 1 },
                    { new Guid("f6f6f6f6-f6f6-f6f6-f6f6-f6f6f6f6f6f6"), "Investment", 0 }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: new Guid("a3a3a3a3-a3a3-a3a3-a3a3-a3a3a3a3a3a3"));

            migrationBuilder.DeleteData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: new Guid("a7a7a7a7-a7a7-a7a7-a7a7-a7a7a7a7a7a7"));

            migrationBuilder.DeleteData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: new Guid("b8b8b8b8-b8b8-b8b8-b8b8-b8b8b8b8b8b8"));

            migrationBuilder.DeleteData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: new Guid("c9c9c9c9-c9c9-c9c9-c9c9-c9c9c9c9c9c9"));

            migrationBuilder.DeleteData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: new Guid("d0d0d0d0-d0d0-d0d0-d0d0-d0d0d0d0d0d0"));

            migrationBuilder.DeleteData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: new Guid("e1e1e1e1-e1e1-e1e1-e1e1-e1e1e1e1e1e1"));

            migrationBuilder.DeleteData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: new Guid("e5e5e5e5-e5e5-e5e5-e5e5-e5e5e5e5e5e5"));

            migrationBuilder.DeleteData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: new Guid("f2f2f2f2-f2f2-f2f2-f2f2-f2f2f2f2f2f2"));

            migrationBuilder.DeleteData(
                table: "Categories",
                keyColumn: "Id",
                keyValue: new Guid("f6f6f6f6-f6f6-f6f6-f6f6-f6f6f6f6f6f6"));
        }
    }
}
