<script setup lang="ts">
import { computed } from 'vue'
import type { GigInvitation } from '@/api/types.gen'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'

const props = defineProps<{
  invitations: GigInvitation[]
  isPoster: boolean
  isLoading?: boolean
}>()

const emit = defineEmits<{
  accept: [invitationUuid: string]
  decline: [invitationUuid: string]
}>()

interface InvitationStatusConfig {
  label: string
  variant: 'default' | 'secondary' | 'destructive' | 'outline'
}

const statusConfig: Record<string, InvitationStatusConfig> = {
  pending: { label: 'Pending', variant: 'secondary' },
  accepted: { label: 'Accepted', variant: 'default' },
  declined: { label: 'Declined', variant: 'destructive' },
  withdrawn: { label: 'Withdrawn', variant: 'outline' },
}

function getStatusConfig(status: string): InvitationStatusConfig {
  return statusConfig[status] ?? { label: status, variant: 'outline' }
}

function getInitials(name: string): string {
  return name
    .split(' ')
    .map((n) => n[0])
    .join('')
    .toUpperCase()
    .slice(0, 2)
}

const hasInvitations = computed(() => props.invitations.length > 0)
</script>

<template>
  <div>
    <div v-if="!hasInvitations" class="text-center py-8 text-muted-foreground">
      <p>No invitations yet</p>
    </div>

    <div v-else class="space-y-3">
      <Card v-for="invitation in invitations" :key="invitation.uuid">
        <CardContent class="p-4">
          <div class="flex items-start justify-between gap-4">
            <!-- Agent info -->
            <div class="flex items-center gap-3 min-w-0">
              <Avatar class="h-10 w-10 shrink-0">
                <AvatarImage
                  v-if="invitation.invited_agent.user_avatar"
                  :src="invitation.invited_agent.user_avatar"
                  :alt="`${invitation.invited_agent.user_first_name} ${invitation.invited_agent.user_last_name}`"
                />
                <AvatarFallback>
                  {{ getInitials(`${invitation.invited_agent.user_first_name} ${invitation.invited_agent.user_last_name}`) }}
                </AvatarFallback>
              </Avatar>
              <div class="min-w-0">
                <p class="font-medium truncate">
                  {{ invitation.invited_agent.user_first_name }} {{ invitation.invited_agent.user_last_name }}
                </p>
                <p v-if="invitation.proposed_rate" class="text-sm text-muted-foreground">
                  Proposed rate: ${{ invitation.proposed_rate }}
                </p>
                <p v-if="invitation.message" class="text-sm text-muted-foreground mt-1 line-clamp-2">
                  {{ invitation.message }}
                </p>
              </div>
            </div>

            <!-- Status + Actions -->
            <div class="flex flex-col items-end gap-2 shrink-0">
              <Badge :variant="getStatusConfig(invitation.status ?? 'pending').variant">
                {{ getStatusConfig(invitation.status ?? 'pending').label }}
              </Badge>

              <div
                v-if="isPoster && invitation.status === 'pending'"
                class="flex gap-2"
              >
                <Button
                  size="sm"
                  variant="default"
                  :disabled="isLoading"
                  @click="emit('accept', invitation.uuid)"
                >
                  Accept
                </Button>
                <Button
                  size="sm"
                  variant="outline"
                  :disabled="isLoading"
                  @click="emit('decline', invitation.uuid)"
                >
                  Decline
                </Button>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  </div>
</template>
