<template>
  <div class="search-widget">
    <div class="search-container">
      <h1>Find Your Perfect Hotel</h1>
      
      <div class="search-form">
        <LocationSelect 
          v-model:location="store.location"
          v-model:location-id="store.locationId"
          @fetch-locations="store.fetchLocations"
          :suggestions="store.locationSuggestions"
          @select-location="store.setLocation"
        />
        
        <DateRangePicker 
          v-model:check-in="store.checkIn"
          v-model:check-out="store.checkOut"
          @dates-changed="store.setDates"
        />
        
        <GuestSelector 
          v-model:adults="store.adults"
          v-model:children="store.children"
          @guests-changed="store.setGuests"
        />
        
        <button 
          @click="store.search" 
          :disabled="!store.canSearch || store.loading"
          class="search-button"
        >
          {{ store.loading ? 'Searching...' : 'Search Hotels' }}
        </button>
      </div>

      <div v-if="store.error" class="error-message">
        {{ store.error }}
      </div>
    </div>

    <ResultsList 
      v-if="store.results"
      :results="store.results"
      @clear="store.clearResults"
    />
  </div>
</template>

<script>
import { useSearchStore } from '../stores/search'
import LocationSelect from './LocationSelect.vue'
import DateRangePicker from './DateRangePicker.vue'
import GuestSelector from './GuestSelector.vue'
import ResultsList from './ResultsList.vue'

export default {
  name: 'SearchWidget',
  components: {
    LocationSelect,
    DateRangePicker,
    GuestSelector,
    ResultsList
  },
  setup() {
    const store = useSearchStore()
    return { store }
  }
}
</script>

<style scoped>
.search-widget {
  max-width: 1200px;
  margin: 0 auto;
  padding: 10px;
}

.search-container {
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  padding: 30px;
}

h1 {
  text-align: center;
  color: #333;
  margin-bottom: 30px;
  font-size: 2rem;
}

.search-form {
  display: inline-flex;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  align-items: end;
}

.search-form > * {
  min-height: 60px;
}

.search-button {
  width: 200px;
  grid-column: 1 / -1;
  background: #007bff;
  color: white;
  border: none;
  padding: 15px 30px;
  border-radius: 6px;
  font-size: 1.1rem;
  cursor: pointer;
  transition: background-color 0.3s;
}

.search-button:hover:not(:disabled) {
  background: #0056b3;
}

.search-button:disabled {
  background: #ccc;
  cursor: not-allowed;
}

.error-message {
  margin-top: 20px;
  padding: 15px;
  background: #f8d7da;
  color: #721c24;
  border: 1px solid #f5c6cb;
  border-radius: 4px;
  text-align: center;
}

@media (max-width: 768px) {
  .search-form {
    grid-template-columns: 1fr;
  }
  
  .search-form > * {
    grid-column: 1;
  }
}
</style>

