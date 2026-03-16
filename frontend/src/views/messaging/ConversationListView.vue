<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useMessaging } from '@/composables/useMessaging'
import { useAuthStore } from '@/stores/auth.store'
import { Card, CardContent } from '@/components/ui/card'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import { Badge } from '@/components/ui/badge'
import { Loader2, MessageSquare } from 'lucide-vue-next'
import type { Conversation, ProfessionalProfile } from '@/api/types.gen'

const router = useRouter()
const authStore = useAuthStore()
const { conversations, isLoading, error, fetchConversations } = useMessaging()

/**
 * Determine the "other" participant in a conversation.
 */
function otherParticipant(conversation: Conversation): ProfessionalProfile {
  const userEmail = authStore.user?.email
  if (conversation.participant_1.user_email === userEmail) {
    return conversation.participant_2
  }
  return conversation.participant_1
}

function participantName(profile: ProfessionalProfile): string {
  return `${profile.user_first_name} ${profile.user_last_name}`.trim() || profile.user_email
}

function participantInitials(profile: ProfessionalProfile): string {
  const first = profile.user_first_name.charAt(0).toUpperCase()
  const last = profile.user_last_name.charAt(0).toUpperCase()
  return `${first}${last}` || '?'
}

function lastMessagePreview(conversation: Conversation): string {
  const msg = conversation.last_message
  if (!msg) return 'No messages yet'
  const body = (msg as Record<string, unknown>)['body']
  if (typeof body !== 'string') return 'No messages yet'
  return body.length > 60 ? body.slice(0, 60) + '...' : body
}

function relativeTime(dateStr: string): string {
  const now = Date.now()
  const created = new Date(dateStr).getTime()
  const diffMs = now - created
  const diffMinutes = Math.floor(diffMs / 60_000)
  const diffHours = Math.floor(diffMs / 3_600_000)
  const diffDays = Math.floor(diffMs / 86_400_000)

  if (diffMinutes < 1) return 'Just now'
  if (diffMinutes < 60) return `${diffMinutes}m ago`
  if (diffHours < 24) return `${diffHours}h ago`
  if (diffDays === 1) return 'Yesterday'
  if (diffDays < 7) return `${diffDays}d ago`

  return new Date(dateStr).toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
  })
}

const sortedConversations = computed(() => {
  return [...conversations.value].sort((a, b) => {
    return new Date(b.modified).getTime() - new Date(a.modified).getTime()
  })
})

function openConversation(uuid: string): void {
  router.push({ name: 'conversation', params: { uuid } })
}

onMounted(async () => {
  await fetchConversations()
})
</script>

<template>
  <div>
    <!-- Header -->
    <div class="mb-6">
      <h1 class="text-2xl font-bold">Messages</h1>
      <p class="text-sm text-muted-foreground mt-1">
        Your conversations
      </p>
    </div>

    <!-- Loading -->
    <div v-if="isLoading" class="flex items-center justify-center py-20">
      <Loader2 :size="32" class="animate-spin text-muted-foreground" />
    </div>

    <!-- Error -->
    <div v-else-if="error" class="text-center py-20">
      <p class="text-destructive">{{ error.message }}</p>
    </div>

    <!-- Empty state -->
    <div v-else-if="sortedConversations.length === 0" class="text-center py-20">
      <MessageSquare :size="48" class="mx-auto text-muted-foreground mb-4" />
      <p class="text-muted-foreground text-lg">No conversations yet</p>
      <p class="text-muted-foreground text-sm mt-1">
        Start a conversation from an agent's profile or a gig
      </p>
    </div>

    <!-- Conversation list -->
    <div v-else class="space-y-2">
      <Card
        v-for="conversation in sortedConversations"
        :key="conversation.uuid"
        class="cursor-pointer hover:bg-accent/50 transition-colors"
        @click="openConversation(conversation.uuid)"
      >
        <CardContent class="p-4">
          <div class="flex items-center gap-3">
            <!-- Avatar -->
            <Avatar class="h-10 w-10 shrink-0">
              <AvatarImage
                v-if="otherParticipant(conversation).user_avatar"
                :src="otherParticipant(conversation).user_avatar"
                :alt="participantName(otherParticipant(conversation))"
              />
              <AvatarFallback class="text-sm">
                {{ participantInitials(otherParticipant(conversation)) }}
              </AvatarFallback>
            </Avatar>

            <!-- Content -->
            <div class="flex-1 min-w-0">
              <div class="flex items-center justify-between gap-2">
                <span class="font-medium text-sm truncate">
                  {{ participantName(otherParticipant(conversation)) }}
                </span>
                <span class="text-xs text-muted-foreground shrink-0">
                  {{ relativeTime(conversation.modified) }}
                </span>
              </div>
              <div class="flex items-center justify-between gap-2 mt-0.5">
                <p class="text-sm text-muted-foreground truncate">
                  {{ lastMessagePreview(conversation) }}
                </p>
                <Badge
                  v-if="conversation.unread_count > 0"
                  variant="default"
                  class="shrink-0"
                >
                  {{ conversation.unread_count }}
                </Badge>
              </div>
              <p
                v-if="conversation.gig"
                class="text-xs text-muted-foreground mt-1"
              >
                Linked to a gig
              </p>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  </div>
</template>
