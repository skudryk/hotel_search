<template>
  <div class="date-range-picker">
    <label>Check-in / Check-out</label>
    <div class="date-inputs">
      <div class="date-input">
        <input
          v-model="checkInValue"
          type="date"
          :min="today"
          :max="maxDate"
          @change="handleDateChange"
          placeholder="Check-in"
        />
        <span class="date-label">Check-in</span>
      </div>
      <div class="date-input">
        <input
          v-model="checkOutValue"
          type="date"
          :min="minCheckOut"
          :max="maxDate"
          @change="handleDateChange"
          placeholder="Check-out"
        />
        <span class="date-label">Check-out</span>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, watch } from 'vue'
import { format, addDays, parseISO, isValid } from 'date-fns'

export default {
  name: 'DateRangePicker',
  props: {
    checkIn: String,
    checkOut: String
  },
  emits: ['update:checkIn', 'update:checkOut', 'datesChanged'],
  setup(props, { emit }) {
    const checkInValue = ref(props.checkIn || '')
    const checkOutValue = ref(props.checkOut || '')

    const today = computed(() => {
      return format(new Date(), 'yyyy-MM-dd')
    })

    const maxDate = computed(() => {
      return format(addDays(new Date(), 365), 'yyyy-MM-dd')
    })

    const minCheckOut = computed(() => {
      if (!checkInValue.value) return today.value
      
      try {
        const checkInDate = parseISO(checkInValue.value)
        if (isValid(checkInDate)) {
          return format(addDays(checkInDate, 1), 'yyyy-MM-dd')
        }
      } catch (error) {
        console.warn('Invalid check-in date:', error)
      }
      
      return today.value
    })

    const handleDateChange = () => {
      // If check-out is before check-in, clear it
      if (checkInValue.value && checkOutValue.value) {
        try {
          const checkInDate = parseISO(checkInValue.value)
          const checkOutDate = parseISO(checkOutValue.value)
          console.log("checkInDate:", checkInDate, "checkOutDate:", checkOutDate)
          

          if (checkOutDate <= checkInDate) {
            console.error('clearing checkOutValue');
            // TODO:  add extra checks if entered values for D/M/Y are valid and only then clear value
            // if the checkOut is invalid (after CheckIn or wrong date at all)
            //checkOutValue.value = ''
          }
        } catch (error) {
          console.warn('Date parsing error:', error)
        }
      }

      emit('update:checkIn', checkInValue.value)
      emit('update:checkOut', checkOutValue.value)
      emit('datesChanged', checkInValue.value, checkOutValue.value)
    }

    // Watch for external changes to props
    watch(() => props.checkIn, (newValue) => {
      if (newValue !== checkInValue.value) {
        checkInValue.value = newValue || ''
      }
    })

    watch(() => props.checkOut, (newValue) => {
      if (newValue !== checkOutValue.value) {
        checkOutValue.value = newValue || ''
      }
    })

    return {
      checkInValue,
      checkOutValue,
      today,
      maxDate,
      minCheckOut,
      handleDateChange
    }
  }
}
</script>

<style scoped>
.date-range-picker {
  position: relative;
}

label {
  display: block;
  margin-bottom: 8px;
  font-weight: 600;
  color: #333;
}

.date-inputs {
  display: flex;
  gap: 12px;
}

.date-input {
  flex: 1;
  position: relative;
}

.date-input input {
  width: 100%;
  padding: 12px 16px;
  border: 2px solid #ddd;
  border-radius: 6px;
  font-size: 1rem;
  transition: border-color 0.3s;
  box-sizing: border-box;
  background: white;
}

.date-input input:focus {
  outline: none;
  border-color: #007bff;
}

.date-label {
  position: absolute;
  top: -8px;
  left: 12px;
  background: white;
  padding: 0 4px;
  font-size: 0.8rem;
  color: #666;
  font-weight: 500;
}

@media (max-width: 768px) {
  .date-inputs {
    flex-direction: column;
    gap: 16px;
  }
}
</style>


