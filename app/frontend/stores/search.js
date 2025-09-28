import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useSearchStore = defineStore('search', () => {
  // State
  const location = ref('')
  const locationId = ref('')
  const checkIn = ref('')
  const checkOut = ref('')
  const adults = ref(1)
  const children = ref(0)
  const loading = ref(false)
  const results = ref(null)
  const error = ref(null)
  const locationSuggestions = ref([])

  // Computed
  const canSearch = computed(() => {
    return locationId.value && 
           checkIn.value && 
           checkOut.value && 
           adults.value >= 1
  })

  // Actions
  const fetchLocations = async (query) => {
    if (!query || query.length < 2) {
      locationSuggestions.value = []
      return
    }

    try {
      const response = await fetch(`/api/locations?q=${encodeURIComponent(query)}`)
      const data = await response.json()
      
      if (response.ok) {
        locationSuggestions.value = data
      } else {
        error.value = data.error?.message || 'Failed to fetch locations'
      }
    } catch (err) {
      error.value = 'Network error while fetching locations'
    }
  }

  const search = async () => {
    if (!canSearch.value) return

    loading.value = true
    error.value = null

    try {
      const params = new URLSearchParams({
        location_id: locationId.value,
        check_in: checkIn.value,
        check_out: checkOut.value,
        adults: adults.value.toString(),
        children: children.value.toString()
      })

      const response = await fetch(`/api/search?${params}`)
      const data = await response.json()

      if (response.ok) {
        results.value = data
      } else {
        error.value = data.error?.message || 'Search failed'
      }
    } catch (err) {
      error.value = 'Network error during search'
    } finally {
      loading.value = false
    }
  }

  const setLocation = (locationData) => {
    location.value = locationData.name || locationData
    locationId.value = locationData.id || locationData
    locationSuggestions.value = []
  }

  const setDates = (checkInDate, checkOutDate) => {
    checkIn.value = checkInDate
    checkOut.value = checkOutDate
  }

  const setGuests = (adultsCount, childrenCount) => {
    adults.value = adultsCount
    children.value = childrenCount
  }

  const clearResults = () => {
    results.value = null
    error.value = null
  }

  return {
    // State
    location,
    locationId,
    checkIn,
    checkOut,
    adults,
    children,
    loading,
    results,
    error,
    locationSuggestions,
    // Computed
    canSearch,
    // Actions
    fetchLocations,
    search,
    setLocation,
    setDates,
    setGuests,
    clearResults
  }
})

