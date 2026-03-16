<script setup lang="ts">
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import { Card, CardContent } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Avatar, AvatarImage, AvatarFallback } from '@/components/ui/avatar'
import { CheckCircle, Star, Clock } from 'lucide-vue-next'
import type { ProfessionalProfile } from '@/api/types.gen'

const props = defineProps<{
  profile: ProfessionalProfile
}>()

const router = useRouter()

const initials = computed((): string => {
  const first = props.profile.user_first_name?.charAt(0) ?? ''
  const last = props.profile.user_last_name?.charAt(0) ?? ''
  return (first + last).toUpperCase()
})

const fullName = computed((): string => {
  return `${props.profile.user_first_name} ${props.profile.user_last_name}`.trim()
})

const rating = computed((): number => {
  return props.profile.average_rating ? parseFloat(props.profile.average_rating) : 0
})

const responseTimeLabel = computed((): string | null => {
  if (!props.profile.average_response_time) return null
  const minutes = parseInt(props.profile.average_response_time, 10)
  if (isNaN(minutes) || minutes <= 0) return null
  if (minutes < 60) return `Responds in ~${minutes}m`
  const hours = Math.round(minutes / 60)
  return `Responds in ~${hours}h`
})

const specializationLabels: Record<string, string> = {
  residential: 'Residential',
  commercial: 'Commercial',
  buyers_agent: "Buyer's Agent",
  listing_agent: 'Listing Agent',
}

function navigateToProfile(): void {
  router.push({ name: 'agent-profile', params: { uuid: props.profile.uuid } })
}
</script>

<template>
  <Card
    class="cursor-pointer transition-shadow hover:shadow-md"
    @click="navigateToProfile"
  >
    <CardContent class="p-5">
      <!-- Header: Avatar + Name -->
      <div class="flex items-start gap-3 mb-3">
        <Avatar class="h-12 w-12 shrink-0">
          <AvatarImage
            v-if="profile.user_avatar"
            :src="profile.user_avatar"
            :alt="fullName"
          />
          <AvatarFallback class="text-sm font-medium">
            {{ initials }}
          </AvatarFallback>
        </Avatar>

        <div class="min-w-0 flex-1">
          <div class="flex items-center gap-1.5">
            <h3 class="text-sm font-semibold truncate">{{ fullName }}</h3>
            <CheckCircle
              v-if="profile.is_verified"
              :size="16"
              class="text-green-500 shrink-0"
            />
          </div>

          <!-- Rating -->
          <div v-if="rating > 0" class="flex items-center gap-1 mt-0.5">
            <Star :size="14" class="text-amber-500 fill-amber-500" />
            <span class="text-xs text-muted-foreground">{{ rating.toFixed(1) }}</span>
          </div>
        </div>

        <!-- Availability dot -->
        <span
          :class="[
            'h-2.5 w-2.5 rounded-full shrink-0 mt-1',
            profile.is_available ? 'bg-green-500' : 'bg-gray-400',
          ]"
          :title="profile.is_available ? 'Available' : 'Unavailable'"
        />
      </div>

      <!-- Response time -->
      <div
        v-if="responseTimeLabel"
        class="flex items-center gap-1 text-xs text-muted-foreground mb-3"
      >
        <Clock :size="12" />
        {{ responseTimeLabel }}
      </div>

      <!-- Service areas -->
      <div v-if="profile.service_areas.length > 0" class="flex flex-wrap gap-1 mb-3">
        <Badge
          v-for="area in profile.service_areas.slice(0, 3)"
          :key="area.uuid"
          variant="secondary"
          class="text-[10px]"
        >
          {{ area.name }}
        </Badge>
        <Badge
          v-if="profile.service_areas.length > 3"
          variant="outline"
          class="text-[10px]"
        >
          +{{ profile.service_areas.length - 3 }}
        </Badge>
      </div>

      <!-- Specializations -->
      <p
        v-if="profile.specializations.length > 0"
        class="text-xs text-muted-foreground truncate"
      >
        {{ profile.specializations.map((s) => specializationLabels[s] ?? s).join(', ') }}
      </p>
    </CardContent>
  </Card>
</template>
