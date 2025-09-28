<template>
  <div class="location-select">
    <label for="location">Location</label>
    <div class="input-container">
      <input
        id="location"
        v-model="inputValue"
        type="text"
        placeholder="Enter city or location"
        @input="handleInput"
        @focus="showSuggestions = true"
        @blur="handleBlur"
        @keydown.down="navigateDown"
        @keydown.up="navigateUp"
        @keydown.enter="selectHighlighted"
        @keydown.escape="showSuggestions = false"
        autocomplete="off"
      />
      <div v-if="showSuggestions && suggestions.length > 0" class="suggestions">
        <div
          v-for="(suggestion, index) in suggestions"
          :key="suggestion.id || index"
          :class="['suggestion-item', { highlighted: index === highlightedIndex }]"
          @mousedown="selectLocation(suggestion)"
        >
          <div class="location-name">{{ suggestion.name || suggestion }}</div>
          <div v-if="suggestion.country" class="location-country">{{ suggestion.country }}</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, watch, nextTick } from 'vue'
import { debounce } from 'lodash-es'

export default {
  name: 'LocationSelect',
  props: {
    location: String,
    locationId: String,
    suggestions: Array
  },
  emits: ['update:location', 'update:locationId', 'fetchLocations', 'selectLocation'],
  setup(props, { emit }) {
    const inputValue = ref(props.location || '')
    const showSuggestions = ref(false)
    const highlightedIndex = ref(-1)

    // Debounced search function
    const debouncedFetch = debounce((query) => {
      emit('fetchLocations', query)
    }, 300)

    const handleInput = () => {
      emit('update:location', inputValue.value)
      highlightedIndex.value = -1
      
      if (inputValue.value.length >= 2) {
        debouncedFetch(inputValue.value)
        showSuggestions.value = true
      } else {
        showSuggestions.value = false
      }
    }

    const handleBlur = () => {
      // Delay hiding suggestions to allow click events to fire
      setTimeout(() => {
        showSuggestions.value = false
        highlightedIndex.value = -1
      }, 200)
    }

    const selectLocation = (suggestion) => {
      const locationData = typeof suggestion === 'string' ? suggestion : suggestion.name
      const locationId = typeof suggestion === 'object' ? suggestion.id : suggestion
      
      inputValue.value = locationData
      emit('update:location', locationData)
      emit('update:locationId', locationId)
      emit('selectLocation', suggestion)
      showSuggestions.value = false
      highlightedIndex.value = -1
    }

    const navigateDown = () => {
      if (highlightedIndex.value < props.suggestions.length - 1) {
        highlightedIndex.value++
      }
    }

    const navigateUp = () => {
      if (highlightedIndex.value > 0) {
        highlightedIndex.value--
      }
    }

    const selectHighlighted = () => {
      if (highlightedIndex.value >= 0 && props.suggestions[highlightedIndex.value]) {
        selectLocation(props.suggestions[highlightedIndex.value])
      }
    }

    // Watch for external changes to location prop
    watch(() => props.location, (newValue) => {
      if (newValue !== inputValue.value) {
        inputValue.value = newValue || ''
      }
    })

    return {
      inputValue,
      showSuggestions,
      highlightedIndex,
      handleInput,
      handleBlur,
      selectLocation,
      navigateDown,
      navigateUp,
      selectHighlighted
    }
  }
}
</script>

<style scoped>
.location-select {
  position: relative;
}

label {
  display: block;
  margin-bottom: 8px;
  font-weight: 600;
  color: #333;
}

.input-container {
  position: relative;
}

input {
  width: 100%;
  padding: 12px 16px;
  border: 2px solid #ddd;
  border-radius: 6px;
  font-size: 1rem;
  transition: border-color 0.3s;
  box-sizing: border-box;
}

input:focus {
  outline: none;
  border-color: #007bff;
}

.suggestions {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  background: white;
  border: 2px solid #007bff;
  border-top: none;
  border-radius: 0 0 6px 6px;
  max-height: 200px;
  overflow-y: auto;
  z-index: 1000;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.suggestion-item {
  padding: 12px 16px;
  cursor: pointer;
  border-bottom: 1px solid #eee;
  transition: background-color 0.2s;
}

.suggestion-item:last-child {
  border-bottom: none;
}

.suggestion-item:hover,
.suggestion-item.highlighted {
  background-color: #f8f9fa;
}

.location-name {
  font-weight: 500;
  color: #333;
}

.location-country {
  font-size: 0.9rem;
  color: #666;
  margin-top: 2px;
}
</style>

