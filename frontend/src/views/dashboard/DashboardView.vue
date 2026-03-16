<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { Briefcase, Bell, MessageSquare, DollarSign, AlertTriangle, XCircle, Plus, Search } from 'lucide-vue-next'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert'
import GigStatusBadge from '@/components/gigs/GigStatusBadge.vue'
import { useProfessionals } from '@/composables/useProfessionals'
import { useGigs } from '@/composables/useGigs'
import { useMessaging } from '@/composables/useMessaging'
import { useAuth } from '@/composables/useAuth'
import type { Gig } from '@/api/types.gen'

const router = useRouter()
const { userName } = useAuth()
const { myProfile, fetchMyProfile, updateProfile } = useProfessionals()
const { myGigs, fetchMyGigs } = useGigs()
const { conversations, fetchConversations } = useMessaging()

const isLoadingDashboard = ref(true)
const isTogglingAvailability = ref(false)

// Computed stats
const activeGigCount = computed<number>(() => {
  return myGigs.value.filter((g: Gig) => g.status === 'in_progress').length
})

const pendingInvitationCount = computed<number>(() => {
  // Gigs in "invited" status where user has been invited
  return myGigs.value.filter((g: Gig) => g.status === 'invited').length
})

const unreadMessageCount = computed<number>(() => {
  return conversations.value.reduce((sum, c) => sum + (c.unread_count ?? 0), 0)
})

const totalEarnings = computed<string>(() => {
  const total = myGigs.value
    .filter((g: Gig) => g.status === 'completed' && g.agreed_price != null)
    .reduce((sum, g) => sum + parseFloat(g.agreed_price ?? '0'), 0)
  return total.toLocaleString('en-US', { style: 'currency', currency: 'USD' })
})

const recentGigs = computed<Gig[]>(() => {
  return [...myGigs.value]
    .sort((a, b) => new Date(b.created).getTime() - new Date(a.created).getTime())
    .slice(0, 5)
})

// Verification status
const licenseStatus = computed(() => myProfile.value?.license_status ?? null)
const isVerified = computed(() => licenseStatus.value === 'verified')
const isRejected = computed(() => licenseStatus.value === 'rejected')
const rejectionReason = computed(() => myProfile.value?.rejection_reason ?? '')
const showVerificationBanner = computed(() => myProfile.value != null && !isVerified.value)

// Availability
const isAvailable = computed(() => myProfile.value?.is_available ?? false)

// Gig type display mapping
const gigTypeLabels: Record<string, string> = {
  showing: 'Showing',
  open_house: 'Open House',
  inspection_accompaniment: 'Inspection',
  other: 'Other',
}

function formatGigType(gig: Gig): string {
  return gigTypeLabels[gig.gig_type ?? 'other'] ?? 'Other'
}

function formatDate(dateStr: string): string {
  return new Date(dateStr).toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  })
}

async function toggleAvailability(): Promise<void> {
  if (!myProfile.value) return
  isTogglingAvailability.value = true
  await updateProfile({ is_available: !myProfile.value.is_available })
  await fetchMyProfile()
  isTogglingAvailability.value = false
}

function navigateTo(path: string): void {
  void router.push(path)
}

onMounted(async () => {
  await Promise.all([
    fetchMyProfile(),
    fetchMyGigs(),
    fetchConversations(),
  ])
  isLoadingDashboard.value = false
})
</script>

<template>
  <div class="space-y-6">
    <!-- Header -->
    <div>
      <h2 class="text-2xl font-bold text-foreground mb-1">Dashboard</h2>
      <p class="text-muted-foreground">
        Welcome back{{ userName ? `, ${userName}` : '' }}
      </p>
    </div>

    <!-- Loading state -->
    <div v-if="isLoadingDashboard" class="space-y-6">
      <div class="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <Card v-for="i in 4" :key="i" class="animate-pulse">
          <CardContent class="p-6">
            <div class="h-4 bg-muted rounded w-24 mb-3" />
            <div class="h-8 bg-muted rounded w-16" />
          </CardContent>
        </Card>
      </div>
    </div>

    <!-- Dashboard content -->
    <template v-else>
      <!-- Row 1: Stats Cards -->
      <div class="grid grid-cols-2 lg:grid-cols-4 gap-4">
        <Card
          class="cursor-pointer transition-colors hover:bg-muted/50"
          @click="navigateTo('/dashboard/gigs')"
        >
          <CardContent class="p-6">
            <div class="flex items-center justify-between mb-2">
              <span class="text-sm font-medium text-muted-foreground">Active Gigs</span>
              <Briefcase class="h-5 w-5 text-muted-foreground" />
            </div>
            <p class="text-3xl font-bold text-foreground">{{ activeGigCount }}</p>
          </CardContent>
        </Card>

        <Card
          class="cursor-pointer transition-colors hover:bg-muted/50"
          @click="navigateTo('/dashboard/gigs')"
        >
          <CardContent class="p-6">
            <div class="flex items-center justify-between mb-2">
              <span class="text-sm font-medium text-muted-foreground">Pending Invitations</span>
              <Bell class="h-5 w-5 text-muted-foreground" />
            </div>
            <p class="text-3xl font-bold text-foreground">{{ pendingInvitationCount }}</p>
          </CardContent>
        </Card>

        <Card
          class="cursor-pointer transition-colors hover:bg-muted/50"
          @click="navigateTo('/dashboard/messages')"
        >
          <CardContent class="p-6">
            <div class="flex items-center justify-between mb-2">
              <span class="text-sm font-medium text-muted-foreground">Unread Messages</span>
              <MessageSquare class="h-5 w-5 text-muted-foreground" />
            </div>
            <p class="text-3xl font-bold text-foreground">{{ unreadMessageCount }}</p>
          </CardContent>
        </Card>

        <Card>
          <CardContent class="p-6">
            <div class="flex items-center justify-between mb-2">
              <span class="text-sm font-medium text-muted-foreground">Earnings</span>
              <DollarSign class="h-5 w-5 text-muted-foreground" />
            </div>
            <p class="text-3xl font-bold text-foreground">{{ totalEarnings }}</p>
          </CardContent>
        </Card>
      </div>

      <!-- Row 2: Verification Banner -->
      <Alert
        v-if="showVerificationBanner && isRejected"
        variant="destructive"
      >
        <XCircle class="h-4 w-4" />
        <AlertTitle>License Verification Rejected</AlertTitle>
        <AlertDescription>
          {{ rejectionReason || 'Your license verification was rejected. Please contact support for more information.' }}
        </AlertDescription>
      </Alert>

      <Alert
        v-else-if="showVerificationBanner"
        class="border-amber-500/50 bg-amber-50 text-amber-900 dark:bg-amber-950 dark:text-amber-200 dark:border-amber-500/30"
      >
        <AlertTriangle class="h-4 w-4 text-amber-600 dark:text-amber-400" />
        <AlertTitle>License Verification Pending</AlertTitle>
        <AlertDescription>
          Your license verification is pending. You'll be able to post gigs and message agents once verified.
        </AlertDescription>
      </Alert>

      <!-- Row 3: Quick Actions -->
      <Card>
        <CardHeader>
          <CardTitle class="text-lg">Quick Actions</CardTitle>
        </CardHeader>
        <CardContent>
          <div class="flex flex-wrap items-center gap-4">
            <div v-if="myProfile" class="flex items-center gap-3">
              <span class="text-sm text-muted-foreground">Availability</span>
              <Button
                :variant="isAvailable ? 'default' : 'outline'"
                size="sm"
                :disabled="isTogglingAvailability"
                @click="toggleAvailability"
              >
                {{ isTogglingAvailability ? 'Updating...' : (isAvailable ? 'Available' : 'Unavailable') }}
              </Button>
            </div>

            <div class="flex items-center gap-3 ml-auto">
              <Button @click="navigateTo('/dashboard/gigs/create')">
                <Plus class="h-4 w-4 mr-2" />
                Create Gig
              </Button>
              <Button variant="outline" @click="navigateTo('/dashboard/agents')">
                <Search class="h-4 w-4 mr-2" />
                Find Agents
              </Button>
            </div>
          </div>
        </CardContent>
      </Card>

      <!-- Row 4: Recent Gigs -->
      <Card>
        <CardHeader>
          <CardTitle class="text-lg">Recent Gigs</CardTitle>
        </CardHeader>
        <CardContent>
          <div v-if="recentGigs.length === 0" class="text-center py-8 text-muted-foreground">
            <Briefcase class="h-10 w-10 mx-auto mb-3 opacity-40" />
            <p>No gigs yet. Create your first gig to get started.</p>
          </div>

          <div v-else class="space-y-3">
            <div
              v-for="gig in recentGigs"
              :key="gig.uuid"
              class="flex items-center justify-between p-3 rounded-lg border hover:bg-muted/50 cursor-pointer transition-colors"
              @click="navigateTo(`/dashboard/gigs/${gig.uuid}`)"
            >
              <div class="min-w-0 flex-1">
                <p class="font-medium text-foreground truncate">{{ gig.title }}</p>
                <p class="text-sm text-muted-foreground">
                  {{ formatDate(gig.scheduled_date) }} &middot; {{ formatGigType(gig) }}
                </p>
              </div>
              <GigStatusBadge :status="gig.status" class="ml-3 shrink-0" />
            </div>
          </div>
        </CardContent>
      </Card>
    </template>
  </div>
</template>
