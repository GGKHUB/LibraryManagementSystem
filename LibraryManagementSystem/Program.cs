using LibraryManagementSystem.Data;
using LibraryManagementSystem.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Identity;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllersWithViews().AddRazorRuntimeCompilation();

// Configure SQLite DB for application data
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// Configure Identity DB (using same SQLite file)
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// Add Identity services
builder.Services.AddDefaultIdentity<ApplicationUser>(options =>
{
    options.SignIn.RequireConfirmedAccount = false;  // Changed to false for demo purposes
})
    .AddEntityFrameworkStores<ApplicationDbContext>();

// Require authentication globally by default (only allow endpoints marked [AllowAnonymous])
builder.Services.AddAuthorization(options =>
{
    options.FallbackPolicy = new Microsoft.AspNetCore.Authorization.AuthorizationPolicyBuilder()
        .RequireAuthenticatedUser()
        .Build();
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.MapRazorPages();

// Database initialization
using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    
    if (app.Environment.IsDevelopment())
    {
        // Development: Use EnsureCreated for app data, Migrate for identity
        var db = services.GetRequiredService<AppDbContext>();
        db.Database.EnsureCreated();
        AppDbContext.SeedData(db);

        var identityDb = services.GetRequiredService<ApplicationDbContext>();
        identityDb.Database.Migrate();
    }
    else
    {
        // Production: Use migrations for proper database versioning
        try
        {
            var db = services.GetRequiredService<AppDbContext>();
            db.Database.Migrate();
            AppDbContext.SeedData(db);

            var identityDb = services.GetRequiredService<ApplicationDbContext>();
            identityDb.Database.Migrate();
        }
        catch (Exception ex)
        {
            var logger = services.GetRequiredService<ILogger<Program>>();
            logger.LogError(ex, "An error occurred while migrating or seeding the database.");
            throw;
        }
    }
}

app.Run();
