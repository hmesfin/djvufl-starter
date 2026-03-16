<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useGigs } from '@/composables/useGigs'
import { useProfessionals } from '@/composables/useProfessionals'
import GigStatusBadge from '@/components/gigs/GigStatusBadge.vue'
import GigInvitationList from '@/components/gigs/GigInvitationList.vue'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/components/ui/card'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from '@/components/ui/dialog'
import {
  MapPin,
  Calendar,
  DollarSign,
  Loader2,
  ArrowLeft,
  UserPlus,
  Clock,
} from 'lucide-vue-next'
import type { Status92cEnum } from '@/api/types.gen'

const props = defineProps<{
  uuid: string
}>()

const route = useRoute()
const router = useRouter()
const {
  currentGig,
  invitations,
  isLoading,
  error,
  fetchGig,
  transitionGig,
  fetchInvitations,
  createInvitation,
  respondToInvitation,
} = useGigs()
const { myProfile, fetchMyProfile } = useProfessionals()

// Dialog state for inviting agent
const showInviteDialog = ref(false)
const inviteAgentUuid = ref('')
const inviteMessage = ref('')
const isInviting = ref(false)

// Status timeline steps
const statusSteps: Array<{ status: Status92cEnum; label: string }> = [
  { status: 'draft', label: 'Draft' },
  { status: 'posted', label: 'Posted' },
  { status: 'invited', label: 'Invited' },
  { status: 'negotiating', label: 'Negotiating' },
  { status: 'accepted', label: 'Accepted' },
  { status: 'in_progress', label: 'In Progress' },
  { status: 'completed', label: 'Completed' },
]

const gigTypeLabels: Record<string, string> = {
  showing: 'Showing',
  open_house: 'Open House',
  inspection_accompaniment: 'Inspection Accompaniment',
  other: 'Other',
}

const gigUuid = computed(() => props.uuid || (route.params['uuid'] as string))

const isPoster = computed(() => {
  if (!currentGig.value || !myProfile.value) return false
  return currentGig.value.posted_by?.uuid === myProfile.value.uuid
})

const isAssignee = computed(() => {
  if (!currentGig.value || !myProfile.value) return false
  return currentGig.value.assigned_to?.uuid === myProfile.value.uuid
})

const currentStepIndex = computed(() => {
  if (!currentGig.value) return -1
  // Handle cancelled/disputed separately
  if (currentGig.value.status === 'cancelled' || currentGig.value.status === 'disputed') {
    return -1
  }
  return statusSteps.findIndex((s) => s.status === currentGig.value?.status)
})

const myInvitation = computed(() => {
  if (!myProfile.value) return null
  return invitations.value.find(
    (inv) => inv.invited_agent?.uuid === myProfile.value?.uuid
  ) ?? null
})

function formatDate(dateStr: string): string {
  const date = new Date(dateStr + 'T00:00:00')
  return date.toLocaleDateString('en-US', {
    weekday: 'long',
    month: 'long',
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

async function handleTransition(status: Status92cEnum): Promise<void> {
  const result = await transitionGig(gigUuid.value, status)
  if (result.success) {
    await fetchGig(gigUuid.value)
  }
}

async function handleInviteAgent(): Promise<void> {
  if (!inviteAgentUuid.value.trim()) return

  isInviting.value = true
  const result = await createInvitation(gigUuid.value, {
    invited_agent_uuid: inviteAgentUuid.value.trim(),
    message: inviteMessage.value || undefined,
  })

  if (result.success) {
    showInviteDialog.value = false
    inviteAgentUuid.value = ''
    inviteMessage.value = ''
  }
  isInviting.value = false
}

async function handleAcceptInvitation(invitationUuid: string): Promise<void> {
  await respondToInvitation(gigUuid.value, invitationUuid, { status: 'accepted' })
  await fetchGig(gigUuid.value)
}

async function handleDeclineInvitation(invitationUuid: string): Promise<void> {
  await respondToInvitation(gigUuid.value, invitationUuid, { status: 'declined' })
}

async function handleAcceptAsAssignee(): Promise<void> {
  if (!myInvitation.value) return
  await respondToInvitation(gigUuid.value, myInvitation.value.uuid, { status: 'accepted' })
  await fetchGig(gigUuid.value)
}

async function handleDeclineAsAssignee(): Promise<void> {
  if (!myInvitation.value) return
  await respondToInvitation(gigUuid.value, myInvitation.value.uuid, { status: 'declined' })
}

onMounted(async () => {
  await Promise.all([
    fetchGig(gigUuid.value),
    fetchInvitations(gigUuid.value),
    fetchMyProfile(),
  ])
})
</script>

<template>
  <div>
    <!-- Back button -->
    <Button
      variant="ghost"
      size="sm"
      class="mb-4"
      @click="router.push({ name: 'gig-list' })"
    >
      <ArrowLeft :size="16" class="mr-1" />
      Back to Gigs
    </Button>

    <!-- Loading -->
    <div v-if="isLoading && !currentGig" class="flex items-center justify-center py-20">
      <Loader2 :size="32" class="animate-spin text-muted-foreground" />
    </div>

    <!-- Error -->
    <div v-else-if="error && !currentGig" class="text-center py-20">
      <p class="text-destructive">{{ error.message }}</p>
      <Button variant="outline" size="sm" class="mt-4" @click="fetchGig(gigUuid)">
        Try again
      </Button>
    </div>

    <!-- Gig detail -->
    <div v-else-if="currentGig" class="space-y-6">
      <!-- Title + Status -->
      <div class="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 class="text-2xl font-bold">{{ currentGig.title }}</h1>
          <p class="text-sm text-muted-foreground mt-1">
            Posted by {{ currentGig.posted_by ? `${currentGig.posted_by.user_first_name} ${currentGig.posted_by.user_last_name}` : 'Unknown' }}
          </p>
        </div>
        <GigStatusBadge :status="currentGig.status" />
      </div>

      <!-- Status Timeline -->
      <Card v-if="currentStepIndex >= 0">
        <CardContent class="p-4">
          <div class="flex items-center gap-1 overflow-x-auto">
            <template v-for="(step, index) in statusSteps" :key="step.status">
              <div
                :class="[
                  'flex items-center gap-1.5 px-2 py-1 rounded text-xs font-medium whitespace-nowrap',
                  index <= currentStepIndex
                    ? 'bg-primary/10 text-primary'
                    : 'bg-muted text-muted-foreground',
                ]"
              >
                <div
                  :class="[
                    'w-2 h-2 rounded-full shrink-0',
                    index < currentStepIndex ? 'bg-primary' : '',
                    index === currentStepIndex ? 'bg-primary ring-2 ring-primary/30' : '',
                    index > currentStepIndex ? 'bg-muted-foreground/30' : '',
                  ]"
                />
                {{ step.label }}
              </div>
              <div
                v-if="index < statusSteps.length - 1"
                :class="[
                  'w-4 h-px shrink-0',
                  index < currentStepIndex ? 'bg-primary' : 'bg-border',
                ]"
              />
            </template>
          </div>
        </CardContent>
      </Card>

      <!-- Cancelled / Disputed banner -->
      <div
        v-if="currentGig.status === 'cancelled'"
        class="rounded-md bg-red-50 dark:bg-red-950 border border-red-200 dark:border-red-800 p-4 text-red-700 dark:text-red-300"
      >
        This gig has been cancelled.
      </div>
      <div
        v-if="currentGig.status === 'disputed'"
        class="rounded-md bg-orange-50 dark:bg-orange-950 border border-orange-200 dark:border-orange-800 p-4 text-orange-700 dark:text-orange-300"
      >
        This gig is currently in dispute.
      </div>

      <!-- Details grid -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <!-- Left: Description & Details -->
        <Card>
          <CardHeader>
            <CardTitle class="text-lg">Details</CardTitle>
          </CardHeader>
          <CardContent class="space-y-4">
            <div v-if="currentGig.description">
              <p class="text-sm text-muted-foreground mb-1">Description</p>
              <p class="text-sm whitespace-pre-wrap">{{ currentGig.description }}</p>
            </div>

            <div class="space-y-3">
              <div class="flex items-center gap-2 text-sm">
                <MapPin :size="16" class="text-muted-foreground shrink-0" />
                <span>{{ currentGig.location_address }}</span>
              </div>
              <div class="flex items-center gap-2 text-sm">
                <Calendar :size="16" class="text-muted-foreground shrink-0" />
                <span>{{ formatDate(currentGig.scheduled_date) }}</span>
              </div>
              <div class="flex items-center gap-2 text-sm">
                <Clock :size="16" class="text-muted-foreground shrink-0" />
                <span>{{ formatTime(currentGig.scheduled_time) }}</span>
              </div>
              <div class="flex items-center gap-2 text-sm">
                <DollarSign :size="16" class="text-muted-foreground shrink-0" />
                <span>
                  Budget: {{ formatBudget(currentGig.budget_range_min, currentGig.budget_range_max) }}
                  <template v-if="currentGig.agreed_price">
                    &middot; Agreed: ${{ currentGig.agreed_price }}
                  </template>
                </span>
              </div>
            </div>

            <div>
              <span class="text-xs text-muted-foreground bg-muted px-2 py-0.5 rounded">
                {{ gigTypeLabels[currentGig.gig_type ?? 'other'] ?? currentGig.gig_type }}
              </span>
            </div>

            <div v-if="currentGig.assigned_to" class="pt-2 border-t">
              <p class="text-sm text-muted-foreground mb-1">Assigned To</p>
              <p class="text-sm font-medium">{{ currentGig.assigned_to.user_first_name }} {{ currentGig.assigned_to.user_last_name }}</p>
            </div>
          </CardContent>
        </Card>

        <!-- Right: Actions & Invitations -->
        <div class="space-y-6">
          <!-- Poster Actions -->
          <Card v-if="isPoster">
            <CardHeader>
              <CardTitle class="text-lg">Actions</CardTitle>
              <CardDescription>Manage this gig's lifecycle</CardDescription>
            </CardHeader>
            <CardContent class="space-y-3">
              <Button
                v-if="currentGig.status === 'draft'"
                class="w-full"
                @click="handleTransition('posted')"
                :disabled="isLoading"
              >
                <Loader2 v-if="isLoading" :size="16" class="mr-2 animate-spin" />
                Post Gig
              </Button>
              <Button
                v-if="currentGig.status === 'posted'"
                variant="destructive"
                class="w-full"
                @click="handleTransition('cancelled')"
                :disabled="isLoading"
              >
                <Loader2 v-if="isLoading" :size="16" class="mr-2 animate-spin" />
                Cancel Gig
              </Button>
              <Button
                v-if="currentGig.status === 'accepted'"
                class="w-full"
                @click="handleTransition('in_progress')"
                :disabled="isLoading"
              >
                <Loader2 v-if="isLoading" :size="16" class="mr-2 animate-spin" />
                Mark In Progress
              </Button>
              <Button
                v-if="currentGig.status === 'in_progress'"
                class="w-full"
                @click="handleTransition('completed')"
                :disabled="isLoading"
              >
                <Loader2 v-if="isLoading" :size="16" class="mr-2 animate-spin" />
                Mark Complete
              </Button>
            </CardContent>
          </Card>

          <!-- Assignee Actions -->
          <Card v-if="isAssignee && myInvitation && myInvitation.status === 'pending'">
            <CardHeader>
              <CardTitle class="text-lg">Your Invitation</CardTitle>
              <CardDescription>You've been invited to this gig</CardDescription>
            </CardHeader>
            <CardContent class="space-y-3">
              <div class="flex gap-3">
                <Button class="flex-1" @click="handleAcceptAsAssignee" :disabled="isLoading">
                  Accept
                </Button>
                <Button
                  variant="outline"
                  class="flex-1"
                  @click="handleDeclineAsAssignee"
                  :disabled="isLoading"
                >
                  Decline
                </Button>
              </div>
            </CardContent>
          </Card>

          <!-- Invitations -->
          <Card>
            <CardHeader>
              <div class="flex items-center justify-between">
                <CardTitle class="text-lg">Invitations</CardTitle>
                <Button
                  v-if="isPoster && (currentGig.status === 'posted' || currentGig.status === 'invited')"
                  size="sm"
                  variant="outline"
                  @click="showInviteDialog = true"
                >
                  <UserPlus :size="14" class="mr-1" />
                  Invite Agent
                </Button>
              </div>
            </CardHeader>
            <CardContent>
              <GigInvitationList
                :invitations="invitations"
                :is-poster="isPoster"
                :is-loading="isLoading"
                @accept="handleAcceptInvitation"
                @decline="handleDeclineInvitation"
              />
            </CardContent>
          </Card>
        </div>
      </div>
    </div>

    <!-- Invite Agent Dialog -->
    <Dialog v-model:open="showInviteDialog">
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Invite Agent</DialogTitle>
          <DialogDescription>
            Enter the agent's UUID to send them an invitation for this gig.
          </DialogDescription>
        </DialogHeader>
        <div class="space-y-4 py-4">
          <div class="space-y-2">
            <Label for="agent-uuid">Agent UUID</Label>
            <Input
              id="agent-uuid"
              v-model="inviteAgentUuid"
              placeholder="Enter agent UUID"
            />
          </div>
          <div class="space-y-2">
            <Label for="invite-message">Message (optional)</Label>
            <Input
              id="invite-message"
              v-model="inviteMessage"
              placeholder="Add a message for the agent"
            />
          </div>
        </div>
        <DialogFooter>
          <Button variant="outline" @click="showInviteDialog = false">
            Cancel
          </Button>
          <Button @click="handleInviteAgent" :disabled="isInviting || !inviteAgentUuid.trim()">
            <Loader2 v-if="isInviting" :size="16" class="mr-2 animate-spin" />
            Send Invitation
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  </div>
</template>
