/**
 * Messaging Composable
 *
 * Provides methods for managing conversations and messages,
 * including polling for new messages.
 */

import { ref } from 'vue'
import { apiClient } from '@/lib/api-client'
import {
  apiConversationsList,
  apiConversationsCreate,
  apiConversationsMessagesList,
  apiConversationsMessagesCreate,
} from '@/api/sdk.gen'
import type {
  Conversation,
  Message,
  ConversationCreateRequest,
  MessageCreateRequest,
} from '@/api/types.gen'
import type { AxiosError } from 'axios'

export interface MessagingError {
  message: string
  field?: string
  details?: Record<string, string[]>
}

/**
 * Parse API error response into MessagingError format
 */
function parseError(error: unknown): MessagingError {
  const axiosError = error as AxiosError<{
    detail?: string
    [key: string]: string | string[] | undefined
  }>

  if (axiosError.response?.data) {
    const data = axiosError.response.data

    if (typeof data.detail === 'string') {
      return { message: data.detail }
    }

    const details: Record<string, string[]> = {}
    let firstError = 'An error occurred'

    for (const [key, value] of Object.entries(data)) {
      if (Array.isArray(value)) {
        details[key] = value
        if (firstError === 'An error occurred') {
          firstError = value[0] ?? 'An error occurred'
        }
      } else if (typeof value === 'string') {
        details[key] = [value]
        if (firstError === 'An error occurred') {
          firstError = value
        }
      }
    }

    return {
      message: firstError,
      details: Object.keys(details).length > 0 ? details : undefined,
    }
  }

  return {
    message: axiosError.message || 'An unexpected error occurred',
  }
}

const POLL_INTERVAL_MS = 30_000

export function useMessaging() {
  const conversations = ref<Conversation[]>([])
  const messages = ref<Message[]>([])
  const isLoading = ref(false)
  const error = ref<MessagingError | null>(null)

  let pollingTimer: ReturnType<typeof setInterval> | null = null

  /**
   * Fetch all conversations for the current user.
   */
  async function fetchConversations(): Promise<{ success: boolean }> {
    error.value = null
    isLoading.value = true

    try {
      const response = await apiConversationsList({
        client: apiClient,
      })

      if (response && 'error' in response && response.error) {
        throw response
      }

      conversations.value = response.data?.results ?? []
      return { success: true }
    } catch (err) {
      error.value = parseError(err)
      return { success: false }
    } finally {
      isLoading.value = false
    }
  }

  /**
   * Create a conversation with another participant, optionally linked to a gig.
   * Returns the existing conversation if one already exists.
   */
  async function createConversation(
    participantUuid: string,
    gigUuid?: string
  ): Promise<{ success: boolean; conversation?: Conversation }> {
    error.value = null
    isLoading.value = true

    try {
      const body: ConversationCreateRequest = {
        participant_uuid: participantUuid,
        gig_uuid: gigUuid ?? null,
      }

      const response = await apiConversationsCreate({
        client: apiClient,
        body,
      })

      if (response && 'error' in response && response.error) {
        throw response
      }

      // The create endpoint returns ConversationCreate (just uuids),
      // but a 200 for existing returns full Conversation. Refresh list.
      await fetchConversations()

      // Return the conversation data (cast since backend returns full object)
      return {
        success: true,
        conversation: response.data as unknown as Conversation,
      }
    } catch (err) {
      error.value = parseError(err)
      return { success: false }
    } finally {
      isLoading.value = false
    }
  }

  /**
   * Fetch messages for a specific conversation.
   */
  async function fetchMessages(
    conversationUuid: string
  ): Promise<{ success: boolean }> {
    error.value = null
    isLoading.value = true

    try {
      const response = await apiConversationsMessagesList({
        client: apiClient,
        path: { conversation_uuid: conversationUuid },
      })

      if (response && 'error' in response && response.error) {
        throw response
      }

      messages.value = response.data?.results ?? []
      return { success: true }
    } catch (err) {
      error.value = parseError(err)
      return { success: false }
    } finally {
      isLoading.value = false
    }
  }

  /**
   * Send a message in a conversation.
   */
  async function sendMessage(
    conversationUuid: string,
    body: string
  ): Promise<{ success: boolean; message?: Message }> {
    error.value = null

    try {
      const requestBody: MessageCreateRequest = { body }

      const response = await apiConversationsMessagesCreate({
        client: apiClient,
        path: { conversation_uuid: conversationUuid },
        body: requestBody,
      })

      if (response && 'error' in response && response.error) {
        throw response
      }

      // Cast because the backend returns full Message with sender, not just MessageCreate
      const newMessage = response.data as unknown as Message
      messages.value = [...messages.value, newMessage]

      return { success: true, message: newMessage }
    } catch (err) {
      error.value = parseError(err)
      return { success: false }
    }
  }

  /**
   * Start polling for new messages in a conversation.
   */
  function startPolling(conversationUuid: string): void {
    stopPolling()
    pollingTimer = setInterval(() => {
      void fetchMessages(conversationUuid)
    }, POLL_INTERVAL_MS)
  }

  /**
   * Stop polling for messages.
   */
  function stopPolling(): void {
    if (pollingTimer !== null) {
      clearInterval(pollingTimer)
      pollingTimer = null
    }
  }

  return {
    // State
    conversations,
    messages,
    isLoading,
    error,

    // Methods
    fetchConversations,
    createConversation,
    fetchMessages,
    sendMessage,
    startPolling,
    stopPolling,
  }
}
