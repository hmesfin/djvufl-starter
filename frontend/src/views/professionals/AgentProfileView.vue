<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useProfessionals } from '@/composables/useProfessionals'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Avatar, AvatarImage, AvatarFallback } from '@/components/ui/avatar'
import {
  CheckCircle,
  Star,
  Clock,
  MapPin,
  ArrowLeft,
  Loader2,
  Send,
} from 'lucide-vue-next'
import type { Review } from '@/api/types.gen'

const route = useRoute()
const router = useRouter()
const { profile, reviews, isLoading, error, fetchProfile, fetchReviews } = useProfessionals()

const reviewCount = ref(0)

const uuid = computed((): string => {
  return route.params['uuid'] as string
})

const initials = computed((): string => {
  if (!profile.value) return ''
  const first = profile.value.user_first_name?.charAt(0) ?? ''
  const last = profile.value.user_last_name?.charAt(0) ?? ''
  return (first + last).toUpperCase()
})

const fullName = computed((): string => {
  if (!profile.value) return ''
  return `${profile.value.user_first_name} ${profile.value.user_last_name}`.trim()
})

const rating = computed((): number => {
  return profile.value?.average_rating ? parseFloat(profile.value.average_rating) : 0
})

const responseTimeLabel = computed((): string | null => {
  if (!profile.value?.average_response_time) return null
  const minutes = parseInt(profile.value.average_response_time, 10)
  if (isNaN(minutes) || minutes <= 0) return null
  if (minutes < 60) return `~${minutes} minutes`
  const hours = Math.round(minutes / 60)
  return `~${hours} hour${hours !== 1 ? 's' : ''}`
})

const specializationLabels: Record<string, string> = {
  residential: 'Residential',
  commercial: 'Commercial',
  buyers_agent: "Buyer's Agent",
  listing_agent: 'Listing Agent',
}

function formatReviewDate(dateStr: string): string {
  return new Date(dateStr).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
  })
}

function renderStars(count: number): string {
  return '\u2605'.repeat(count) + '\u2606'.repeat(5 - count)
}

function getReviewerName(review: Review): string {
  if (!review.reviewer) return 'Anonymous'
  return `${review.reviewer.user_first_name} ${review.reviewer.user_last_name}`.trim()
}

function goBack(): void {
  router.push({ name: 'agent-directory' })
}

onMounted(async () => {
  const [profileResult, reviewsResult] = await Promise.all([
    fetchProfile(uuid.value),
    fetchReviews(uuid.value),
  ])

  if (profileResult.success && reviewsResult.success) {
    reviewCount.value = reviewsResult.total ?? 0
  }
})
</script>

<template>
  <div>
    <!-- Back button -->
    <Button variant="ghost" size="sm" class="mb-4 -ml-2" @click="goBack">
      <ArrowLeft :size="16" class="mr-1" />
      Back to Directory
    </Button>

    <!-- Loading -->
    <div v-if="isLoading && !profile" class="flex items-center justify-center py-20">
      <Loader2 :size="32" class="animate-spin text-muted-foreground" />
    </div>

    <!-- Error -->
    <div v-else-if="error && !profile" class="text-center py-20">
      <p class="text-destructive">{{ error.message }}</p>
      <Button variant="outline" size="sm" class="mt-4" @click="goBack">
        Back to Directory
      </Button>
    </div>

    <!-- Profile Content -->
    <div v-else-if="profile" class="space-y-6">
      <!-- Profile Header Card -->
      <Card>
        <CardContent class="p-6">
          <div class="flex flex-col sm:flex-row items-start gap-5">
            <Avatar class="h-20 w-20 shrink-0">
              <AvatarImage
                v-if="profile.user_avatar"
                :src="profile.user_avatar"
                :alt="fullName"
              />
              <AvatarFallback class="text-xl font-semibold">
                {{ initials }}
              </AvatarFallback>
            </Avatar>

            <div class="flex-1 min-w-0">
              <div class="flex items-center gap-2 flex-wrap">
                <h1 class="text-2xl font-bold">{{ fullName }}</h1>
                <CheckCircle
                  v-if="profile.is_verified"
                  :size="20"
                  class="text-green-500"
                />
                <Badge
                  :variant="profile.is_available ? 'default' : 'secondary'"
                  class="ml-auto sm:ml-0"
                >
                  {{ profile.is_available ? 'Available' : 'Unavailable' }}
                </Badge>
              </div>

              <!-- Rating & Response Time -->
              <div class="flex items-center gap-4 mt-2 text-sm text-muted-foreground">
                <div v-if="rating > 0" class="flex items-center gap-1">
                  <Star :size="16" class="text-amber-500 fill-amber-500" />
                  <span class="font-medium text-foreground">{{ rating.toFixed(1) }}</span>
                  <span>({{ reviewCount }} review{{ reviewCount !== 1 ? 's' : '' }})</span>
                </div>
                <div v-if="responseTimeLabel" class="flex items-center gap-1">
                  <Clock :size="14" />
                  <span>Responds in {{ responseTimeLabel }}</span>
                </div>
              </div>

              <!-- Specializations -->
              <div
                v-if="profile.specializations.length > 0"
                class="flex flex-wrap gap-1.5 mt-3"
              >
                <Badge
                  v-for="spec in profile.specializations"
                  :key="spec"
                  variant="outline"
                >
                  {{ specializationLabels[spec] ?? spec }}
                </Badge>
              </div>
            </div>

            <!-- Invite Button -->
            <Button class="shrink-0 mt-3 sm:mt-0">
              <Send :size="16" class="mr-1.5" />
              Invite to Gig
            </Button>
          </div>
        </CardContent>
      </Card>

      <!-- Bio -->
      <Card v-if="profile.bio">
        <CardHeader>
          <CardTitle class="text-lg">About</CardTitle>
        </CardHeader>
        <CardContent>
          <p class="text-sm text-muted-foreground whitespace-pre-line">{{ profile.bio }}</p>
        </CardContent>
      </Card>

      <!-- Service Areas -->
      <Card v-if="profile.service_areas.length > 0">
        <CardHeader>
          <CardTitle class="text-lg">Service Areas</CardTitle>
        </CardHeader>
        <CardContent>
          <div class="flex flex-wrap gap-2">
            <Badge
              v-for="area in profile.service_areas"
              :key="area.uuid"
              variant="secondary"
              class="flex items-center gap-1"
            >
              <MapPin :size="12" />
              {{ area.name }}
            </Badge>
          </div>
        </CardContent>
      </Card>

      <!-- Reviews -->
      <Card>
        <CardHeader>
          <CardTitle class="text-lg">
            Reviews
            <span v-if="reviewCount > 0" class="text-muted-foreground font-normal">
              ({{ reviewCount }})
            </span>
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div v-if="reviews.length === 0" class="text-sm text-muted-foreground">
            No reviews yet.
          </div>
          <div v-else class="space-y-4">
            <div
              v-for="review in reviews"
              :key="review.uuid"
              class="border-b border-border last:border-0 pb-4 last:pb-0"
            >
              <div class="flex items-center justify-between mb-1">
                <span class="text-sm font-medium">{{ getReviewerName(review) }}</span>
                <span class="text-xs text-muted-foreground">
                  {{ formatReviewDate(review.created) }}
                </span>
              </div>
              <div class="text-amber-500 text-sm mb-1">
                {{ renderStars(review.rating) }}
              </div>
              <p v-if="review.comment" class="text-sm text-muted-foreground">
                {{ review.comment }}
              </p>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  </div>
</template>
