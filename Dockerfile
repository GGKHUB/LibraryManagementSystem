# Build stage
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY LibraryManagementSystem/*.csproj ./LibraryManagementSystem/
RUN dotnet restore LibraryManagementSystem/LibraryManagementSystem.csproj

COPY LibraryManagementSystem/. ./LibraryManagementSystem/
RUN dotnet publish LibraryManagementSystem/LibraryManagementSystem.csproj -c Release -o /app/out

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app

COPY --from=build /app/out .

ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

ENTRYPOINT ["dotnet", "LibraryManagementSystem.dll"]
