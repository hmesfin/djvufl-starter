/**
 * Professionals Composable
 *
 * Provides methods for managing professional profiles, searching the directory,
 * and fetching service areas. Integrates with the generated API client.
 */

import { ref } from 'vue'
import { apiClient } from '@/lib/api-client'
import {
  apiProfessionalsMeRetrieve,
  apiProfessionalsMeCreate,
  apiProfessionalsMePartialUpdate,
  apiProfessionalsList,
  apiServiceAreasList,
} from '@/api/sdk.gen'
import type {
  MyProfessionalProfile,
  ProfessionalProfile,
  ServiceArea,
  ProfessionalProfileCreateRequestWritable,
  PatchedProfessionalProfileCreateRequestWritable,
} from '@/api/types.gen'
import type { AxiosError } from 'axios'

export interface ProfessionalError {
  message: string
  field?: string
  details?: Record<string, string[]>
}

export interface SearchParams {
  search?: string
  is_available?: boolean
  ordering?: string
  page?: number
}

/**
 * Parse API error response into ProfessionalError format
 */
function parseError(error: unknown): ProfessionalError {
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

export function useProfessionals() {
  const myProfile = ref<MyProfessionalProfile | null>(null)
  const professionals = ref<ProfessionalProfile[]>([])
  const serviceAreas = ref<ServiceArea[]>([])
  const isLoading = ref(false)
  const error = ref<ProfessionalError | null>(null)

  /**
   * Fetch the current user's professional profile.
   * Returns { success: true } if profile exists, { success: false, notFound: true } if 404.
   */
  async function fetchMyProfile(): Promise<{ success: boolean; notFound?: boolean }> {
    error.value = null
    isLoading.value = true

    try {
      const response = await apiProfessionalsMeRetrieve({
        client: apiClient,
      })

      if (response && 'error' in response && response.error) {
        throw response
      }

      myProfile.value = response.data ?? null
      return { success: true }
    } catch (err) {
      const axiosErr = err as AxiosError
      if (axiosErr.response?.status === 404) {
        myProfile.value = null
        return { success: false, notFound: true }
      }
      error.value = parseError(err)
      return { success: false }
    } finally {
      isLoading.value = false
    }
  }

  /**
   * Create a new professional profile for the current user.
   */
  async function createProfile(
    data: ProfessionalProfileCreateRequestWritable
  ): Promise<{ success: boolean }> {
    error.value = null
    isLoading.value = true

    try {
      const response = await apiProfessionalsMeCreate({
        client: apiClient,
        body: data,
      })

      if (response && 'error' in response && response.error) {
        throw response
      }

      myProfile.value = response.data ?? null
      return { success: true }
    } catch (err) {
      error.value = parseError(err)
      return { success: false }
    } finally {
      isLoading.value = false
    }
  }

  /**
   * Update the current user's professional profile.
   */
  async function updateProfile(
    data: PatchedProfessionalProfileCreateRequestWritable
  ): Promise<{ success: boolean }> {
    error.value = null
    isLoading.value = true

    try {
      const response = await apiProfessionalsMePartialUpdate({
        client: apiClient,
        body: data,
      })

      if (response && 'error' in response && response.error) {
        throw response
      }

      myProfile.value = response.data ?? null
      return { success: true }
    } catch (err) {
      error.value = parseError(err)
      return { success: false }
    } finally {
      isLoading.value = false
    }
  }

  /**
   * Search the professional directory with optional filters.
   */
  async function searchProfessionals(
    params?: SearchParams
  ): Promise<{ success: boolean; total?: number }> {
    error.value = null
    isLoading.value = true

    try {
      const response = await apiProfessionalsList({
        client: apiClient,
        query: params,
      })

      if (response && 'error' in response && response.error) {
        throw response
      }

      professionals.value = response.data?.results ?? []
      return { success: true, total: response.data?.count }
    } catch (err) {
      error.value = parseError(err)
      return { success: false }
    } finally {
      isLoading.value = false
    }
  }

  /**
   * Fetch all available service areas.
   */
  async function fetchServiceAreas(): Promise<{ success: boolean }> {
    error.value = null

    try {
      const response = await apiServiceAreasList({
        client: apiClient,
      })

      if (response && 'error' in response && response.error) {
        throw response
      }

      serviceAreas.value = response.data?.results ?? []
      return { success: true }
    } catch (err) {
      error.value = parseError(err)
      return { success: false }
    }
  }

  return {
    // State
    myProfile,
    professionals,
    serviceAreas,
    isLoading,
    error,

    // Methods
    fetchMyProfile,
    createProfile,
    updateProfile,
    searchProfessionals,
    fetchServiceAreas,
  }
}
