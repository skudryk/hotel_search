<template>
  <div class="guest-selector">
    <label>Guests</label>
    <div class="guest-inputs">
      <div class="guest-input">
        <label for="adults">Adults</label>
        <div class="number-input">
          <button 
            type="button" 
            @click="decreaseAdults"
            :disabled="adultsValue <= 1"
            class="number-button"
          >
            −
          </button>
          <input
            id="adults"
            v-model.number="adultsValue"
            type="number"
            min="1"
            max="20"
            @change="handleAdultsChange"
            class="number-field"
          />
          <button 
            type="button" 
            @click="increaseAdults"
            :disabled="adultsValue >= 20"
            class="number-button"
          >
            +
          </button>
        </div>
      </div>
      
      <div class="guest-input">
        <label for="children">Children</label>
        <div class="number-input">
          <button 
            type="button" 
            @click="decreaseChildren"
            :disabled="childrenValue <= 0"
            class="number-button"
          >
            −
          </button>
          <input
            id="children"
            v-model.number="childrenValue"
            type="number"
            min="0"
            max="10"
            @change="handleChildrenChange"
            class="number-field"
          />
          <button 
            type="button" 
            @click="increaseChildren"
            :disabled="childrenValue >= 10"
            class="number-button"
          >
            +
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, watch } from 'vue'

export default {
  name: 'GuestSelector',
  props: {
    adults: {
      type: Number,
      default: 1
    },
    children: {
      type: Number,
      default: 0
    }
  },
  emits: ['update:adults', 'update:children', 'guestsChanged'],
  setup(props, { emit }) {
    const adultsValue = ref(props.adults || 1)
    const childrenValue = ref(props.children || 0)

    const decreaseAdults = () => {
      if (adultsValue.value > 1) {
        adultsValue.value--
        handleAdultsChange()
      }
    }

    const increaseAdults = () => {
      if (adultsValue.value < 20) {
        adultsValue.value++
        handleAdultsChange()
      }
    }

    const decreaseChildren = () => {
      if (childrenValue.value > 0) {
        childrenValue.value--
        handleChildrenChange()
      }
    }

    const increaseChildren = () => {
      if (childrenValue.value < 10) {
        childrenValue.value++
        handleChildrenChange()
      }
    }

    const handleAdultsChange = () => {
      // Ensure minimum value
      if (adultsValue.value < 1) {
        adultsValue.value = 1
      }
      if (adultsValue.value > 20) {
        adultsValue.value = 20
      }
      
      emit('update:adults', adultsValue.value)
      emit('guestsChanged', adultsValue.value, childrenValue.value)
    }

    const handleChildrenChange = () => {
      // Ensure valid range
      if (childrenValue.value < 0) {
        childrenValue.value = 0
      }
      if (childrenValue.value > 10) {
        childrenValue.value = 10
      }
      
      emit('update:children', childrenValue.value)
      emit('guestsChanged', adultsValue.value, childrenValue.value)
    }

    // Watch for external changes to props
    watch(() => props.adults, (newValue) => {
      if (newValue !== adultsValue.value) {
        adultsValue.value = newValue || 1
      }
    })

    watch(() => props.children, (newValue) => {
      if (newValue !== childrenValue.value) {
        childrenValue.value = newValue || 0
      }
    })

    return {
      adultsValue,
      childrenValue,
      decreaseAdults,
      increaseAdults,
      decreaseChildren,
      increaseChildren,
      handleAdultsChange,
      handleChildrenChange
    }
  }
}
</script>

<style scoped>
.guest-selector {
  position: relative;
}

label {
  display: block;
  margin-bottom: 8px;
  font-weight: 600;
  color: #333;
}

.guest-inputs {
  display: flex;
  gap: 16px;
}

.guest-input {
  flex: 1;
}

.guest-input label {
  font-size: 0.9rem;
  margin-bottom: 6px;
  font-weight: 500;
  color: #666;
}

.number-input {
  display: flex;
  align-items: center;
  border: 2px solid #ddd;
  border-radius: 6px;
  overflow: hidden;
  transition: border-color 0.3s;
}

.number-input:focus-within {
  border-color: #007bff;
}

.number-button {
  background: #f8f9fa;
  border: none;
  padding: 12px 16px;
  cursor: pointer;
  font-size: 1.2rem;
  font-weight: bold;
  color: #333;
  transition: background-color 0.2s;
  user-select: none;
}

.number-button:hover:not(:disabled) {
  background: #e9ecef;
}

.number-button:disabled {
  background: #f8f9fa;
  color: #ccc;
  cursor: not-allowed;
}

.number-field {
  flex: 1;
  padding: 12px 8px;
  border: none;
  text-align: center;
  font-size: 1rem;
  font-weight: 600;
  color: #333;
  background: white;
  outline: none;
}

.number-field::-webkit-outer-spin-button,
.number-field::-webkit-inner-spin-button {
  -webkit-appearance: none;
  margin: 0;
}

.number-field[type=number] {
  -moz-appearance: textfield;
}

@media (max-width: 768px) {
  .guest-inputs {
    flex-direction: column;
    gap: 12px;
  }
}
</style>

