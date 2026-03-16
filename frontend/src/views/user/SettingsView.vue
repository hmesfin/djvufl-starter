<script setup lang="ts">
import { onMounted } from 'vue'
import PlaceholderCard from '@/components/PlaceholderCard.vue'
import { useProfessionals } from '@/composables/useProfessionals'
import { usePayments } from '@/composables/usePayments'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/components/ui/card'
import { CreditCard, Loader2 } from 'lucide-vue-next'

const { myProfile, fetchMyProfile } = useProfessionals()
const { isLoading: isPaymentLoading, error: paymentError, initiateStripeConnect } = usePayments()

async function handleConnectStripe(): Promise<void> {
  await initiateStripeConnect()
}

onMounted(async () => {
  await fetchMyProfile()
})
</script>

<template>
  <div class="space-y-6">
    <div>
      <h2 class="text-2xl font-bold text-foreground mb-2">Settings</h2>
      <p class="text-muted-foreground">Manage your account settings and preferences</p>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
      <PlaceholderCard
        title="Profile Settings"
        description="Update your personal information and preferences"
      />

      <PlaceholderCard
        title="Account Security"
        description="Set up two-factor authentication and manage your security settings"
      />

      <PlaceholderCard
        title="Notification Preferences"
        description="Manage your notification settings and preferences"
      />

      <!-- Payment Account (Stripe Connect) -->
      <Card v-if="myProfile">
        <CardHeader>
          <div class="flex items-center justify-between">
            <div class="flex items-center gap-3">
              <CreditCard class="h-8 w-8 text-muted-foreground" />
              <div>
                <CardTitle>Payment Account</CardTitle>
                <CardDescription v-if="myProfile.has_stripe_account">
                  Your payment account is set up. You'll receive payouts for completed gigs.
                </CardDescription>
                <CardDescription v-else>
                  Connect your bank account to receive payments for completed gigs.
                </CardDescription>
              </div>
            </div>
            <Badge
              v-if="myProfile.has_stripe_account"
              variant="outline"
              class="bg-green-100 text-green-700 border-green-200 dark:bg-green-900 dark:text-green-300 dark:border-green-800"
            >
              Connected
            </Badge>
          </div>
        </CardHeader>
        <CardContent v-if="!myProfile.has_stripe_account">
          <div v-if="paymentError" class="text-sm text-destructive mb-3">
            {{ paymentError.message }}
          </div>
          <Button
            @click="handleConnectStripe"
            :disabled="isPaymentLoading"
          >
            <Loader2 v-if="isPaymentLoading" :size="16" class="mr-2 animate-spin" />
            Connect with Stripe
          </Button>
        </CardContent>
      </Card>

      <!-- Fallback placeholder when no professional profile -->
      <PlaceholderCard
        v-else
        title="Connected Accounts"
        description="Manage your connected social and third-party accounts"
      />
    </div>
  </div>
</template>
