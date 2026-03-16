<script setup lang="ts">
import { ref, watch } from 'vue'
import { Checkbox } from '@/components/ui/checkbox'
import { Label } from '@/components/ui/label'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import type { ServiceArea, SpecializationsEnum } from '@/api/types.gen'

export interface AgentFilters {
  serviceAreaUuid: string | undefined
  availableOnly: boolean
  minimumRating: string
  specializations: SpecializationsEnum[]
}

defineProps<{
  serviceAreas: ServiceArea[]
}>()

const emit = defineEmits<{
  'filter-change': [filters: AgentFilters]
}>()

const serviceAreaUuid = ref<string | undefined>(undefined)
const availableOnly = ref(false)
const minimumRating = ref('any')
const specializations = ref<SpecializationsEnum[]>([])

const specializationOptions: { value: SpecializationsEnum; label: string }[] = [
  { value: 'residential', label: 'Residential' },
  { value: 'commercial', label: 'Commercial' },
  { value: 'buyers_agent', label: "Buyer's Agent" },
  { value: 'listing_agent', label: 'Listing Agent' },
]

const ratingOptions = [
  { value: 'any', label: 'Any rating' },
  { value: '3', label: '3+ stars' },
  { value: '4', label: '4+ stars' },
  { value: '4.5', label: '4.5+ stars' },
]

function toggleSpecialization(spec: SpecializationsEnum): void {
  const index = specializations.value.indexOf(spec)
  if (index === -1) {
    specializations.value = [...specializations.value, spec]
  } else {
    specializations.value = specializations.value.filter((s) => s !== spec)
  }
}

function emitFilters(): void {
  emit('filter-change', {
    serviceAreaUuid: serviceAreaUuid.value,
    availableOnly: availableOnly.value,
    minimumRating: minimumRating.value,
    specializations: specializations.value,
  })
}

watch([serviceAreaUuid, availableOnly, minimumRating, specializations], emitFilters, {
  deep: true,
})
</script>

<template>
  <div class="space-y-5">
    <!-- Service Area -->
    <div class="space-y-2">
      <Label class="text-sm font-medium">Service Area</Label>
      <Select v-model="serviceAreaUuid">
        <SelectTrigger class="w-full">
          <SelectValue placeholder="All areas" />
        </SelectTrigger>
        <SelectContent>
          <SelectItem value="all">All areas</SelectItem>
          <SelectItem
            v-for="area in serviceAreas"
            :key="area.uuid"
            :value="area.uuid"
          >
            {{ area.name }}
          </SelectItem>
        </SelectContent>
      </Select>
    </div>

    <!-- Availability -->
    <div class="flex items-center gap-2">
      <Checkbox
        id="available-only"
        :checked="availableOnly"
        @update:checked="availableOnly = $event as boolean"
      />
      <Label for="available-only" class="text-sm cursor-pointer">
        Available only
      </Label>
    </div>

    <!-- Minimum Rating -->
    <div class="space-y-2">
      <Label class="text-sm font-medium">Minimum Rating</Label>
      <Select v-model="minimumRating">
        <SelectTrigger class="w-full">
          <SelectValue placeholder="Any rating" />
        </SelectTrigger>
        <SelectContent>
          <SelectItem
            v-for="opt in ratingOptions"
            :key="opt.value"
            :value="opt.value"
          >
            {{ opt.label }}
          </SelectItem>
        </SelectContent>
      </Select>
    </div>

    <!-- Specializations -->
    <div class="space-y-2">
      <Label class="text-sm font-medium">Specializations</Label>
      <div class="space-y-2">
        <div
          v-for="spec in specializationOptions"
          :key="spec.value"
          class="flex items-center gap-2"
        >
          <Checkbox
            :id="`spec-${spec.value}`"
            :checked="specializations.includes(spec.value)"
            @update:checked="toggleSpecialization(spec.value)"
          />
          <Label :for="`spec-${spec.value}`" class="text-sm cursor-pointer">
            {{ spec.label }}
          </Label>
        </div>
      </div>
    </div>
  </div>
</template>
