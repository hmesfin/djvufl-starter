<script setup lang="ts">
import { computed } from 'vue'
import type { Message } from '@/api/types.gen'
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar'

const props = defineProps<{
  message: Message
  isOwn: boolean
}>()

const senderName = computed((): string => {
  const s = props.message.sender
  return `${s.user_first_name} ${s.user_last_name}`.trim() || s.user_email
})

const senderInitials = computed((): string => {
  const s = props.message.sender
  const first = s.user_first_name.charAt(0).toUpperCase()
  const last = s.user_last_name.charAt(0).toUpperCase()
  return `${first}${last}` || '?'
})

const relativeTime = computed((): string => {
  const now = Date.now()
  const created = new Date(props.message.created).getTime()
  const diffMs = now - created
  const diffMinutes = Math.floor(diffMs / 60_000)
  const diffHours = Math.floor(diffMs / 3_600_000)
  const diffDays = Math.floor(diffMs / 86_400_000)

  if (diffMinutes < 1) return 'Just now'
  if (diffMinutes === 1) return '1 minute ago'
  if (diffMinutes < 60) return `${diffMinutes} minutes ago`
  if (diffHours === 1) return '1 hour ago'
  if (diffHours < 24) return `${diffHours} hours ago`
  if (diffDays === 1) return 'Yesterday'
  if (diffDays < 7) return `${diffDays} days ago`

  return new Date(props.message.created).toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  })
})
</script>

<template>
  <div
    :class="[
      'flex gap-2 max-w-[80%]',
      isOwn ? 'ml-auto flex-row-reverse' : 'mr-auto',
    ]"
  >
    <!-- Avatar -->
    <Avatar class="h-8 w-8 shrink-0">
      <AvatarImage
        v-if="message.sender.user_avatar"
        :src="message.sender.user_avatar"
        :alt="senderName"
      />
      <AvatarFallback class="text-xs">{{ senderInitials }}</AvatarFallback>
    </Avatar>

    <!-- Bubble -->
    <div class="flex flex-col gap-1">
      <span
        :class="[
          'text-xs text-muted-foreground',
          isOwn ? 'text-right' : 'text-left',
        ]"
      >
        {{ senderName }}
      </span>
      <div
        :class="[
          'rounded-lg px-3 py-2 text-sm whitespace-pre-wrap break-words',
          isOwn
            ? 'bg-primary text-primary-foreground rounded-tr-sm'
            : 'bg-muted text-foreground rounded-tl-sm',
        ]"
      >
        {{ message.body }}
      </div>
      <span
        :class="[
          'text-xs text-muted-foreground',
          isOwn ? 'text-right' : 'text-left',
        ]"
      >
        {{ relativeTime }}
      </span>
    </div>
  </div>
</template>
