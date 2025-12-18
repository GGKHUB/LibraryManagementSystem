# Home Library (ASP.NET Core MVC)

Small ASP.NET Core MVC application to manage books in your home library.

Features
- Add, edit, view, delete books
- Search by Title, ISBN and Location (Home / Work / Loaned)
- Uses SQLite for local database

Quick start (Windows PowerShell)
1. Restore packages: dotnet restore
2. (Optional) Install EF tool: dotnet tool install --global dotnet-ef
3. Add migration (recommended) and update DB:
   dotnet ef migrations add Initial -p LibraryManagementSystem -s LibraryManagementSystem
   dotnet ef database update -p LibraryManagementSystem -s LibraryManagementSystem
4. Run:
   cd LibraryManagementSystem; dotnet run

Open https://localhost:5001 or the URL shown in the terminal.

Notes
- The project seeds a few example books on first run.
- For a quick run without migrations the app calls EnsureCreated(); the recommended approach for development is to use migrations.

Future ideas
- Add import/export (CSV)
- Add authentication and per-user libraries
- Add advanced filters and paging
