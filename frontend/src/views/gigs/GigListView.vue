<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useGigs } from '@/composables/useGigs'
import GigStatusBadge from '@/components/gigs/GigStatusBadge.vue'
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'
import { Plus, Loader2, MapPin, Calendar, DollarSign } from 'lucide-vue-next'

const router = useRouter()
const { myGigs, marketplaceGigs, isLoading, error, fetchMyGigs, fetchMarketplaceGigs } = useGigs()

const activeTab = ref<'my-gigs' | 'marketplace'>('my-gigs')

const gigTypeLabels: Record<string, string> = {
  showing: 'Showing',
  open_house: 'Open House',
  inspection_accompaniment: 'Inspection Accompaniment',
  other: 'Other',
}

const currentGigs = computed(() => {
  return activeTab.value === 'my-gigs' ? myGigs.value : marketplaceGigs.value
})

function formatDate(dateStr: string): string {
  const date = new Date(dateStr + 'T00:00:00')
  return date.toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  })
}

function formatTime(timeStr: string): string {
  const [hours, minutes] = timeStr.split(':')
  const h = parseInt(hours ?? '0', 10)
  const ampm = h >= 12 ? 'PM' : 'AM'
  const displayHour = h % 12 || 12
  return `${displayHour}:${minutes} ${ampm}`
}

function formatBudget(min: string | null | undefined, max: string | null | undefined): string {
  if (min && max) return `$${min} - $${max}`
  if (min) return `From $${min}`
  if (max) return `Up to $${max}`
  return 'Not specified'
}

function navigateToGig(uuid: string): void {
  router.push({ name: 'gig-detail', params: { uuid } })
}

async function switchTab(tab: 'my-gigs' | 'marketplace'): Promise<void> {
  activeTab.value = tab
  if (tab === 'my-gigs') {
    await fetchMyGigs()
  } else {
    await fetchMarketplaceGigs()
  }
}

onMounted(async () => {
  await fetchMyGigs()
})
</script>

<template>
  <div>
    <!-- Header -->
    <div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between mb-6">
      <div>
        <h1 class="text-2xl font-bold">Gigs</h1>
        <p class="text-sm text-muted-foreground mt-1">
          Manage your gigs or browse the marketplace
        </p>
      </div>
      <Button @click="router.push({ name: 'gig-create' })">
        <Plus :size="16" class="mr-2" />
        Create Gig
      </Button>
    </div>

    <!-- Tabs -->
    <div class="flex gap-1 mb-6 border-b border-border">
      <button
        :class="[
          'px-4 py-2 text-sm font-medium border-b-2 transition-colors -mb-px',
          activeTab === 'my-gigs'
            ? 'border-primary text-foreground'
            : 'border-transparent text-muted-foreground hover:text-foreground',
        ]"
        @click="switchTab('my-gigs')"
      >
        My Gigs
      </button>
      <button
        :class="[
          'px-4 py-2 text-sm font-medium border-b-2 transition-colors -mb-px',
          activeTab === 'marketplace'
            ? 'border-primary text-foreground'
            : 'border-transparent text-muted-foreground hover:text-foreground',
        ]"
        @click="switchTab('marketplace')"
      >
        Marketplace
      </button>
    </div>

    <!-- Loading -->
    <div v-if="isLoading" class="flex items-center justify-center py-20">
      <Loader2 :size="32" class="animate-spin text-muted-foreground" />
    </div>

    <!-- Error -->
    <div v-else-if="error" class="text-center py-20">
      <p class="text-destructive">{{ error.message }}</p>
      <Button
        variant="outline"
        size="sm"
        class="mt-4"
        @click="activeTab === 'my-gigs' ? fetchMyGigs() : fetchMarketplaceGigs()"
      >
        Try again
      </Button>
    </div>

    <!-- Empty state -->
    <div v-else-if="currentGigs.length === 0" class="text-center py-20">
      <p class="text-muted-foreground text-lg">
        {{ activeTab === 'my-gigs' ? 'You have no gigs yet' : 'No gigs available in the marketplace' }}
      </p>
      <p v-if="activeTab === 'my-gigs'" class="text-muted-foreground text-sm mt-1">
        Create your first gig to get started
      </p>
      <Button
        v-if="activeTab === 'my-gigs'"
        class="mt-4"
        @click="router.push({ name: 'gig-create' })"
      >
        <Plus :size="16" class="mr-2" />
        Create Gig
      </Button>
    </div>

    <!-- Gig list -->
    <div v-else class="space-y-3">
      <Card
        v-for="gig in currentGigs"
        :key="gig.uuid"
        class="cursor-pointer hover:bg-accent/50 transition-colors"
        @click="navigateToGig(gig.uuid)"
      >
        <CardContent class="p-4">
          <div class="flex items-start justify-between gap-4">
            <div class="min-w-0 flex-1">
              <div class="flex items-center gap-2 mb-1">
                <h3 class="font-semibold truncate">{{ gig.title }}</h3>
                <GigStatusBadge :status="gig.status" />
              </div>

              <div class="flex flex-wrap gap-x-4 gap-y-1 text-sm text-muted-foreground mt-2">
                <span class="flex items-center gap-1">
                  <MapPin :size="14" />
                  {{ gig.location_address }}
                </span>
                <span class="flex items-center gap-1">
                  <Calendar :size="14" />
                  {{ formatDate(gig.scheduled_date) }} at {{ formatTime(gig.scheduled_time) }}
                </span>
                <span class="flex items-center gap-1">
                  <DollarSign :size="14" />
                  {{ formatBudget(gig.budget_range_min, gig.budget_range_max) }}
                </span>
              </div>

              <div class="mt-2">
                <span class="text-xs text-muted-foreground bg-muted px-2 py-0.5 rounded">
                  {{ gigTypeLabels[gig.gig_type ?? 'other'] ?? gig.gig_type }}
                </span>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  </div>
</template>
