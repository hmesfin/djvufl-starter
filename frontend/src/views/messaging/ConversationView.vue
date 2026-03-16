<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, nextTick, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useMessaging } from '@/composables/useMessaging'
import { useAuthStore } from '@/stores/auth.store'
import MessageBubble from '@/components/messaging/MessageBubble.vue'
import { Button } from '@/components/ui/button'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'
import { Loader2, ArrowLeft, Send } from 'lucide-vue-next'
import type { Conversation, ProfessionalProfile } from '@/api/types.gen'

const props = defineProps<{
  uuid: string
}>()

const router = useRouter()
const authStore = useAuthStore()
const {
  conversations,
  messages,
  isLoading,
  error,
  fetchConversations,
  fetchMessages,
  sendMessage,
  startPolling,
  stopPolling,
} = useMessaging()

const messageBody = ref('')
const isSending = ref(false)
const messagesContainer = ref<HTMLElement | null>(null)

/**
 * Find the current conversation from the loaded list.
 */
const conversation = computed((): Conversation | null => {
  return conversations.value.find((c) => c.uuid === props.uuid) ?? null
})

/**
 * Determine the other participant.
 */
const otherParticipant = computed((): ProfessionalProfile | null => {
  if (!conversation.value) return null
  const userEmail = authStore.user?.email
  if (conversation.value.participant_1.user_email === userEmail) {
    return conversation.value.participant_2
  }
  return conversation.value.participant_1
})

const otherName = computed((): string => {
  if (!otherParticipant.value) return 'Unknown'
  const p = otherParticipant.value
  return `${p.user_first_name} ${p.user_last_name}`.trim() || p.user_email
})

const otherInitials = computed((): string => {
  if (!otherParticipant.value) return '?'
  const p = otherParticipant.value
  const first = p.user_first_name.charAt(0).toUpperCase()
  const last = p.user_last_name.charAt(0).toUpperCase()
  return `${first}${last}` || '?'
})

/**
 * Check if a message was sent by the current user.
 */
function isOwnMessage(senderEmail: string): boolean {
  return senderEmail === authStore.user?.email
}

/**
 * Scroll the message container to the bottom.
 */
function scrollToBottom(): void {
  if (messagesContainer.value) {
    messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight
  }
}

/**
 * Handle sending a message.
 */
async function handleSend(): Promise<void> {
  const body = messageBody.value.trim()
  if (!body || isSending.value) return

  isSending.value = true
  messageBody.value = ''

  const result = await sendMessage(props.uuid, body)

  if (result.success) {
    await nextTick()
    scrollToBottom()
  } else {
    // Restore the message body if send failed
    messageBody.value = body
  }

  isSending.value = false
}

/**
 * Handle keydown in the textarea: Enter sends, Shift+Enter adds newline.
 */
function handleKeydown(event: KeyboardEvent): void {
  if (event.key === 'Enter' && !event.shiftKey) {
    event.preventDefault()
    void handleSend()
  }
}

// Watch for new messages and scroll to bottom
watch(
  () => messages.value.length,
  async () => {
    await nextTick()
    scrollToBottom()
  }
)

onMounted(async () => {
  // Load conversations first to get participant info
  if (conversations.value.length === 0) {
    await fetchConversations()
  }

  // Load messages
  await fetchMessages(props.uuid)
  await nextTick()
  scrollToBottom()

  // Start polling
  startPolling(props.uuid)
})

onUnmounted(() => {
  stopPolling()
})
</script>

<template>
  <div class="flex flex-col h-[calc(100vh-8rem)]">
    <!-- Header -->
    <div class="flex items-center gap-3 pb-4 border-b border-border shrink-0">
      <Button
        variant="ghost"
        size="sm"
        @click="router.push({ name: 'conversation-list' })"
      >
        <ArrowLeft :size="18" />
      </Button>

      <template v-if="otherParticipant">
        <Avatar class="h-9 w-9">
          <AvatarImage
            v-if="otherParticipant.user_avatar"
            :src="otherParticipant.user_avatar"
            :alt="otherName"
          />
          <AvatarFallback class="text-sm">{{ otherInitials }}</AvatarFallback>
        </Avatar>

        <div class="flex-1 min-w-0">
          <RouterLink
            :to="{ name: 'agent-profile', params: { uuid: otherParticipant.uuid } }"
            class="font-medium text-sm hover:underline"
          >
            {{ otherName }}
          </RouterLink>
          <p
            v-if="conversation?.gig"
            class="text-xs text-muted-foreground"
          >
            Linked to a gig
          </p>
        </div>
      </template>
      <template v-else>
        <span class="text-sm text-muted-foreground">Loading...</span>
      </template>
    </div>

    <!-- Messages area -->
    <div
      ref="messagesContainer"
      class="flex-1 overflow-y-auto py-4 space-y-4"
    >
      <!-- Loading -->
      <div v-if="isLoading && messages.length === 0" class="flex items-center justify-center py-20">
        <Loader2 :size="32" class="animate-spin text-muted-foreground" />
      </div>

      <!-- Error -->
      <div v-else-if="error && messages.length === 0" class="text-center py-20">
        <p class="text-destructive">{{ error.message }}</p>
      </div>

      <!-- Empty state -->
      <div v-else-if="messages.length === 0" class="text-center py-20">
        <p class="text-muted-foreground">No messages yet. Start the conversation!</p>
      </div>

      <!-- Message bubbles -->
      <MessageBubble
        v-for="msg in messages"
        :key="msg.uuid"
        :message="msg"
        :is-own="isOwnMessage(msg.sender.user_email)"
      />
    </div>

    <!-- Input area -->
    <div class="shrink-0 pt-4 border-t border-border">
      <div class="flex items-end gap-2">
        <textarea
          v-model="messageBody"
          placeholder="Type a message..."
          rows="1"
          class="flex-1 resize-none rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 min-h-[40px] max-h-[120px]"
          @keydown="handleKeydown"
        />
        <Button
          size="sm"
          :disabled="!messageBody.trim() || isSending"
          @click="handleSend"
        >
          <Loader2 v-if="isSending" :size="16" class="animate-spin" />
          <Send v-else :size="16" />
        </Button>
      </div>
    </div>
  </div>
</template>
