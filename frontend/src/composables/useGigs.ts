/**
 * Gigs Composable
 *
 * Provides methods for managing gigs, marketplace browsing,
 * status transitions, and invitation management.
 */

import { ref } from 'vue'
import { apiClient } from '@/lib/api-client'
import {
  apiGigsList,
  apiGigsCreate,
  apiGigsRetrieve,
  apiGigsTransitionCreate,
  apiGigsInvitationsList,
  apiGigsInvitationsCreate,
  apiGigsInvitationsPartialUpdate,
} from '@/api/sdk.gen'
import type {
  Gig,
  GigCreate,
  GigInvitation,
  GigCreateRequestWritable,
  GigStatusTransitionRequest,
  GigInvitationCreateRequest,
  PatchedGigInvitationRequest,
  Status92cEnum,
} from '@/api/types.gen'
import type { AxiosError } from 'axios'

export interface GigError {
  message: string
  field?: string
  details?: Record<string, string[]>
}

/**
 * Parse API error response into GigError format
 */
function parseError(error: unknown): GigError {
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

export function useGigs() {
  const myGigs = ref<Gig[]>([])
  const marketplaceGigs = ref<Gig[]>([])
  const currentGig = ref<Gig | null>(null)
  const invitations = ref<GigInvitation[]>([])
  const isLoading = ref(false)
  const error = ref<GigError | null>(null)

  /**
   * Fetch the current user's gigs (posted or assigned).
   */
  async function fetchMyGigs(): Promise<{ success: boolean; total?: number }> {
    error.value = null
    isLoading.value = true

    try {
      const response = await apiGigsList({
        client: apiClient,
      })

      if (response && 'error' in response && response.error) {
        throw response
      }

      myGigs.value = response.data?.results ?? []
      return { success: true, total: response.data?.count }
    } catch (err) {
      error.value = parseError(err)
      return { success: false }
    } finally {
      isLoading.value = false
    }
  }

  /**
   * Fetch marketplace gigs (all posted gigs available for agents).
   * Uses a query param to filter for marketplace-visible gigs.
   */
  async function fetchMarketplaceGigs(): Promise<{ success: boolean; total?: number }> {
    error.value = null
    isLoading.value = true

    try {
      // The API may support a marketplace filter; for now we fetch all gigs
      // and the backend filters by posted status for marketplace view
      const response = await apiGigsList({
        client: apiClient,
      })

      if (response && 'error' in response && response.error) {
        throw response
      }

      // Filter to only posted gigs for marketplace view
      const allGigs = response.data?.results ?? []
      marketplaceGigs.value = allGigs.filter((g) => g.status === 'posted')
      return { success: true, total: marketplaceGigs.value.length }
    } catch (err) {
      error.value = parseError(err)
      return { success: false }
    } finally {
      isLoading.value = false
    }
  }

  /**
   * Fetch a single gig by UUID.
   */
  async function fetchGig(uuid: string): Promise<{ success: boolean }> {
    error.value = null
    isLoading.value = true

    try {
      const response = await apiGigsRetrieve({
        client: apiClient,
        path: { uuid },
      })

      if (response && 'error' in response && response.error) {
        throw response
      }

      currentGig.value = response.data ?? null
      return { success: true }
    } catch (err) {
      error.value = parseError(err)
      return { success: false }
    } finally {
      isLoading.value = false
    }
  }

  /**
   * Create a new gig.
   */
  async function createGig(
    data: GigCreateRequestWritable
  ): Promise<{ success: boolean; gig?: GigCreate }> {
    error.value = null
    isLoading.value = true

    try {
      const response = await apiGigsCreate({
        client: apiClient,
        body: data,
      })

      if (response && 'error' in response && response.error) {
        throw response
      }

      return { success: true, gig: response.data ?? undefined }
    } catch (err) {
      error.value = parseError(err)
      return { success: false }
    } finally {
      isLoading.value = false
    }
  }

  /**
   * Transition a gig's status (e.g. draft -> posted, accepted -> in_progress).
   */
  async function transitionGig(
    uuid: string,
    status: Status92cEnum
  ): Promise<{ success: boolean }> {
    error.value = null
    isLoading.value = true

    try {
      const body: GigStatusTransitionRequest = { status }
      const response = await apiGigsTransitionCreate({
        client: apiClient,
        path: { uuid },
        body,
      })

      if (response && 'error' in response && response.error) {
        throw response
      }

      currentGig.value = response.data ?? null
      return { success: true }
    } catch (err) {
      error.value = parseError(err)
      return { success: false }
    } finally {
      isLoading.value = false
    }
  }

  /**
   * Fetch invitations for a specific gig.
   */
  async function fetchInvitations(gigUuid: string): Promise<{ success: boolean }> {
    error.value = null

    try {
      const response = await apiGigsInvitationsList({
        client: apiClient,
        path: { gig_uuid: gigUuid },
      })

      if (response && 'error' in response && response.error) {
        throw response
      }

      invitations.value = response.data?.results ?? []
      return { success: true }
    } catch (err) {
      error.value = parseError(err)
      return { success: false }
    }
  }

  /**
   * Create an invitation for a gig.
   */
  async function createInvitation(
    gigUuid: string,
    data: GigInvitationCreateRequest
  ): Promise<{ success: boolean }> {
    error.value = null
    isLoading.value = true

    try {
      const response = await apiGigsInvitationsCreate({
        client: apiClient,
        path: { gig_uuid: gigUuid },
        body: data,
      })

      if (response && 'error' in response && response.error) {
        throw response
      }

      // Refresh invitations list
      await fetchInvitations(gigUuid)
      return { success: true }
    } catch (err) {
      error.value = parseError(err)
      return { success: false }
    } finally {
      isLoading.value = false
    }
  }

  /**
   * Respond to an invitation (accept, decline, etc.).
   */
  async function respondToInvitation(
    gigUuid: string,
    invitationUuid: string,
    data: PatchedGigInvitationRequest
  ): Promise<{ success: boolean }> {
    error.value = null
    isLoading.value = true

    try {
      const response = await apiGigsInvitationsPartialUpdate({
        client: apiClient,
        path: { gig_uuid: gigUuid, uuid: invitationUuid },
        body: data,
      })

      if (response && 'error' in response && response.error) {
        throw response
      }

      // Refresh invitations list
      await fetchInvitations(gigUuid)
      return { success: true }
    } catch (err) {
      error.value = parseError(err)
      return { success: false }
    } finally {
      isLoading.value = false
    }
  }

  return {
    // State
    myGigs,
    marketplaceGigs,
    currentGig,
    invitations,
    isLoading,
    error,

    // Methods
    fetchMyGigs,
    fetchMarketplaceGigs,
    fetchGig,
    createGig,
    transitionGig,
    fetchInvitations,
    createInvitation,
    respondToInvitation,
  }
}
