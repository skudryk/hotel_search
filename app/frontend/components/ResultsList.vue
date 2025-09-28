<template>
  <div class="results-list">
    <div class="results-header">
      <h2>Search Results</h2>
      <div class="results-actions">
        <button @click="toggleView" class="view-toggle">
          {{ showRawJson ? 'Show Cards' : 'Show Raw JSON' }}
        </button>
        <button @click="$emit('clear')" class="clear-button">
          Clear Results
        </button>
      </div>
    </div>

    <div v-if="showRawJson" class="raw-json">
      <pre>{{ formattedJson }}</pre>
    </div>

    <div v-else class="results-cards">
      <div v-if="isArray" class="card-grid">
        <div 
          v-for="(result, index) in results" 
          :key="index"
          class="result-card"
        >
          <h3>{{ result.name || result.title || `Result ${index + 1}` }}</h3>
          <div v-if="result.description" class="description">
            {{ result.description }}
          </div>
          <div v-if="result.price" class="price">
            ${{ result.price }}
          </div>
          <div v-if="result.location" class="location">
            📍 {{ result.location }}
          </div>
          <div v-if="result.rating" class="rating">
            ⭐ {{ result.rating }}/5
          </div>
        </div>
      </div>

      <div v-else class="single-result">
        <div class="result-card">
          <h3>{{ results.name || results.title || 'Search Result' }}</h3>
          <div v-if="results.description" class="description">
            {{ results.description }}
          </div>
          <div v-if="results.price" class="price">
            ${{ results.price }}
          </div>
          <div v-if="results.location" class="location">
            📍 {{ results.location }}
          </div>
          <div v-if="results.rating" class="rating">
            ⭐ {{ results.rating }}/5
          </div>
        </div>
      </div>
    </div>

    <div v-if="isEmpty" class="no-results">
      <p>No results found. Try adjusting your search criteria.</p>
    </div>
  </div>
</template>

<script>
import { ref, computed } from 'vue'

export default {
  name: 'ResultsList',
  props: {
    results: {
      type: [Object, Array],
      required: true
    }
  },
  emits: ['clear'],
  setup(props) {
    const showRawJson = ref(false)

    const formattedJson = computed(() => {
      return JSON.stringify(props.results, null, 2)
    })

    const isArray = computed(() => {
      return Array.isArray(props.results)
    })

    const isEmpty = computed(() => {
      if (Array.isArray(props.results)) {
        return props.results.length === 0
      }
      return !props.results || Object.keys(props.results).length === 0
    })

    const toggleView = () => {
      showRawJson.value = !showRawJson.value
    }

    return {
      showRawJson,
      formattedJson,
      isArray,
      isEmpty,
      toggleView
    }
  }
}
</script>

<style scoped>
.results-list {
  margin-top: 30px;
  padding: 20px;
  background: #f8f9fa;
  border-radius: 8px;
}

.results-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.results-header h2 {
  margin: 0;
  color: #333;
}

.results-actions {
  display: flex;
  gap: 10px;
}

.view-toggle,
.clear-button {
  padding: 8px 16px;
  border: 1px solid #ddd;
  border-radius: 4px;
  background: white;
  cursor: pointer;
  font-size: 0.9rem;
  transition: all 0.2s;
}

.view-toggle:hover,
.clear-button:hover {
  background: #f8f9fa;
  border-color: #007bff;
}

.clear-button {
  color: #dc3545;
  border-color: #dc3545;
}

.clear-button:hover {
  background: #dc3545;
  color: white;
}

.raw-json {
  background: #2d3748;
  color: #e2e8f0;
  padding: 20px;
  border-radius: 6px;
  overflow-x: auto;
}

.raw-json pre {
  margin: 0;
  font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
  font-size: 0.9rem;
  line-height: 1.5;
}

.card-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
}

.result-card {
  background: white;
  border-radius: 8px;
  padding: 20px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  transition: transform 0.2s, box-shadow 0.2s;
}

.result-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
}

.result-card h3 {
  margin: 0 0 12px 0;
  color: #333;
  font-size: 1.2rem;
}

.description {
  color: #666;
  margin-bottom: 12px;
  line-height: 1.5;
}

.price {
  font-size: 1.3rem;
  font-weight: bold;
  color: #28a745;
  margin-bottom: 8px;
}

.location,
.rating {
  color: #666;
  font-size: 0.9rem;
  margin-bottom: 4px;
}

.no-results {
  text-align: center;
  padding: 40px 20px;
  color: #666;
}

.no-results p {
  margin: 0;
  font-size: 1.1rem;
}

@media (max-width: 768px) {
  .results-header {
    flex-direction: column;
    gap: 15px;
    align-items: stretch;
  }

  .results-actions {
    justify-content: center;
  }

  .card-grid {
    grid-template-columns: 1fr;
  }
}
</style>

