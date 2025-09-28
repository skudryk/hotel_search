# Hotel Search Vue.js based  Widget

A SPA application for hotel search with location autocomplete, date range selection, and guest management. Built with Ruby on Rails 7.1 API backend and Vue.js 3 frontend.

## 🏗️ Architecture

- **Backend**: Ruby on Rails 7.1 (API mode)
- **Frontend**: Vue.js 3 with Vite
- **Database**: SQLite3
- **Caching**: Redis
- **State Management**: Pinia
- **Authentication**: Client ID/Secret (Basic Auth)

## 📋 Prerequisites

Ensure you have the following installed:

- **Ruby**: 3.2.1 (managed with RVM)
- **Node.js**: 20.22.0 (managed with NVM), the minimum version for Node.js is 20.19
- **Redis**

### Install Prerequisites

#### Install RVM (Ruby Version Manager)
```bash
curl -sSL https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm
rvm install 3.2.1
```

#### Install NVM (Node Version Manager)
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install 22.20.0 
```

#### Install Redis
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install redis-server

# macOS
brew install redis

# Start Redis service
sudo systemctl start redis-server  # Linux
brew services start redis          # macOS
```

## 🚀 Installation

### 1. Clone the Repository
```bash
git clone <repository-url>
cd hotel_search
```

### 2. Set Up Ruby Environment
```bash
# Use the correct Ruby version
rvm use 3.2.1

# Install bundler if not already installed
gem install bundler

# Install Ruby dependencies
bundle install
```

### 3. Set Up Node.js Environment
```bash
# Use the correct Node.js version (minimum required 20.19)
nvm use 22.20.0   

# Install Node.js dependencies
npm install
```

### 4. Set Up Vite for Frontend
```bash
# Install Vite Rails integration
bundle exec vite install

# Install Vue.js plugin
npm install @vitejs/plugin-vue --save-dev

bundle exec vite build --mode development
```

### 5. Database Setup
```bash
# Create and migrate database
bundle exec rails db:create
bundle exec rails db:migrate
```

use foreman

### 6. Environment Configuration

Create a `.env` file in the root directory:

```bash
# External API Configuration
CLIENT_ID=your_client_id_here
CLIENT_SECRET=your_client_secret_here
API_BASE_URL="https://app.boomnow.com/open_api/v1"

# Redis Configuration
REDIS_URL=redis://localhost:6379/0

# Rails Configuration
RAILS_ENV=development
```

## 🔧 Configuration

### Redis Configuration

The application uses Redis for caching. Ensure Redis is running and accessible:

```bash
# Check if Redis is running
redis-cli ping
# Should return: PONG
```

## 🏃‍♂️ Running the Application

### Development Mode

1. **Start Redis** (if not already running):
```bash
redis-server
```

2. **Start the Rails server and Vite**:
``` bash
bin/dev - run both servers

# or in separate tabs
bundle exec rails server -p 3000
bin/vite dev
```

3. **Access the application**:
Open your browser and navigate to `http://localhost:3000`

## 🧪 Testing

### Running Tests

```bash

# Run tests with coverage
bundle exec rspec --format documentation
```

## 🔌 API Endpoints

### GET /api/locations
Search for locations with autocomplete.

**Parameters:**
- `q` (string, required): Search query (minimum 2 characters)

**Example:**
```bash
curl "http://localhost:3000/api/locations?q=New%20York"
```

**Response:**
```json
[
  {
    "id": "123",
    "name": "New York",
    "country": "USA"
  }
]
```

### GET /api/search
Search for hotels based on criteria.

**Parameters:**
- `location_id` (string, required): Location identifier
- `check_in` (date, required): Check-in date (YYYY-MM-DD)
- `check_out` (date, required): Check-out date (YYYY-MM-DD)
- `adults` (integer, required): Number of adults (1-20)
- `children` (integer, optional): Number of children (0-10)

**Example:**
```bash
curl "http://localhost:3000/api/search?location_id=123&check_in=2024-01-15&check_out=2024-01-20&adults=2&children=1"
```

**Response:**
```json
{
  "hotels": [
    {
      "name": "Grand Hotel",
      "price": 150,
      "location": "New York",
      "rating": 4.5
    }
  ]
}
```

## 🎨 Frontend Components

### SearchWidget
Main search interface component that orchestrates all search functionality.

### LocationSelect
Location dropdown with live search and autocomplete functionality.

### DateRangePicker
Date selection component with validation for check-in/check-out dates.

### GuestSelector
Guest count selector with numeric controls for adults and children.

### ResultsList
Results display component with toggle between card view and raw JSON.

## 🔒 Security

### Authentication
- Uses Basic Authentication with Client ID/Secret
- Credentials stored in environment variables

### Input Validation
- Parameter sanitization
- Date range validation
- Query length limits
- Numeric range validation


This project is licensed under the MIT License - see the LICENSE file for details.
