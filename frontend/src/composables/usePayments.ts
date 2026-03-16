/**
 * Payments Composable
 *
 * Provides methods for Stripe Connect onboarding and fetching payment status
 * for gigs. Integrates with the generated API client.
 */

import { ref } from 'vue'
import { apiClient } from '@/lib/api-client'
import {
  apiPaymentsStripeConnectCreate,
  apiPaymentsRetrieve,
} from '@/api/sdk.gen'
import type { PaymentDetailResponse } from '@/api/types.gen'
import type { AxiosError } from 'axios'

export interface PaymentError {
  message: string
  details?: Record<string, string[]>
}

/**
 * Parse API error response into PaymentError format
 */
function parseError(error: unknown): PaymentError {
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

export function usePayments() {
  const isLoading = ref(false)
  const error = ref<PaymentError | null>(null)
  const paymentStatus = ref<PaymentDetailResponse | null>(null)

  /**
   * Initiate Stripe Connect onboarding.
   * POSTs to /api/payments/stripe-connect/ and redirects the user to Stripe's
   * hosted onboarding page.
   */
  async function initiateStripeConnect(): Promise<{ success: boolean }> {
    error.value = null
    isLoading.value = true

    try {
      const response = await apiPaymentsStripeConnectCreate({
        client: apiClient,
      })

      if (response && 'error' in response && response.error) {
        throw response
      }

      const url = response.data?.url
      if (url) {
        window.location.href = url
      }

      return { success: true }
    } catch (err) {
      error.value = parseError(err)
      return { success: false }
    } finally {
      isLoading.value = false
    }
  }

  /**
   * Fetch payment status for a specific gig.
   */
  async function fetchPaymentStatus(
    gigUuid: string
  ): Promise<{ success: boolean }> {
    error.value = null
    isLoading.value = true

    try {
      const response = await apiPaymentsRetrieve({
        client: apiClient,
        path: { gig_uuid: gigUuid },
      })

      if (response && 'error' in response && response.error) {
        throw response
      }

      paymentStatus.value = response.data ?? null
      return { success: true }
    } catch (err) {
      const axiosErr = err as AxiosError
      if (axiosErr.response?.status === 404) {
        paymentStatus.value = null
        return { success: true }
      }
      error.value = parseError(err)
      return { success: false }
    } finally {
      isLoading.value = false
    }
  }

  return {
    // State
    isLoading,
    error,
    paymentStatus,

    // Methods
    initiateStripeConnect,
    fetchPaymentStatus,
  }
}
