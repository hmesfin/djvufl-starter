<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useProfessionals } from '@/composables/useProfessionals'
import AgentCard from '@/components/professionals/AgentCard.vue'
import AgentSearchFilters from '@/components/professionals/AgentSearchFilters.vue'
import type { AgentFilters } from '@/components/professionals/AgentSearchFilters.vue'
import { Input } from '@/components/ui/input'
import { Button } from '@/components/ui/button'
import { Search, Loader2 } from 'lucide-vue-next'

const { professionals, serviceAreas, isLoading, error, searchProfessionals, fetchServiceAreas } =
  useProfessionals()

const searchQuery = ref('')
const totalCount = ref(0)
const currentFilters = ref<AgentFilters>({
  serviceAreaUuid: undefined,
  availableOnly: false,
  minimumRating: 'any',
  specializations: [],
})

async function performSearch(): Promise<void> {
  const params: Record<string, unknown> = {}

  if (searchQuery.value.trim()) {
    params['search'] = searchQuery.value.trim()
  }

  if (currentFilters.value.availableOnly) {
    params['is_available'] = true
  }

  const result = await searchProfessionals(params as {
    search?: string
    is_available?: boolean
    ordering?: string
    page?: number
  })

  if (result.success) {
    totalCount.value = result.total ?? 0
  }
}

function handleFilterChange(filters: AgentFilters): void {
  currentFilters.value = filters
  performSearch()
}

function handleSearchSubmit(): void {
  performSearch()
}

onMounted(async () => {
  await Promise.all([performSearch(), fetchServiceAreas()])
})
</script>

<template>
  <div>
    <!-- Header -->
    <div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between mb-6">
      <div>
        <h1 class="text-2xl font-bold">Search Agents</h1>
        <p class="text-sm text-muted-foreground mt-1">
          {{ totalCount }} agent{{ totalCount !== 1 ? 's' : '' }} found
        </p>
      </div>
    </div>

    <div class="flex flex-col lg:flex-row gap-6">
      <!-- Sidebar Filters -->
      <aside class="w-full lg:w-64 shrink-0">
        <div class="sticky top-20 space-y-6">
          <!-- Search input -->
          <form class="flex gap-2" @submit.prevent="handleSearchSubmit">
            <Input
              v-model="searchQuery"
              placeholder="Search by name..."
              class="flex-1"
            />
            <Button type="submit" size="icon" variant="outline">
              <Search :size="16" />
            </Button>
          </form>

          <AgentSearchFilters
            :service-areas="serviceAreas"
            @filter-change="handleFilterChange"
          />
        </div>
      </aside>

      <!-- Main Content -->
      <div class="flex-1 min-w-0">
        <!-- Loading -->
        <div
          v-if="isLoading"
          class="flex items-center justify-center py-20"
        >
          <Loader2 :size="32" class="animate-spin text-muted-foreground" />
        </div>

        <!-- Error -->
        <div
          v-else-if="error"
          class="text-center py-20"
        >
          <p class="text-destructive">{{ error.message }}</p>
          <Button variant="outline" size="sm" class="mt-4" @click="performSearch">
            Try again
          </Button>
        </div>

        <!-- Empty -->
        <div
          v-else-if="professionals.length === 0"
          class="text-center py-20"
        >
          <p class="text-muted-foreground text-lg">No agents found matching your criteria</p>
          <p class="text-muted-foreground text-sm mt-1">
            Try adjusting your filters or search terms
          </p>
        </div>

        <!-- Grid -->
        <div
          v-else
          class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4"
        >
          <AgentCard
            v-for="prof in professionals"
            :key="prof.uuid"
            :profile="prof"
          />
        </div>
      </div>
    </div>
  </div>
</template>
