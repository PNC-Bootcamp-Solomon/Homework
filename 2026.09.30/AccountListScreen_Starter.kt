package com.pnc.jetpackcompostdemos

//
// AccountListScreen_Starter.kt
// Module 12 — Android UI Development
// Lab Exercise: PNC Mobile — Accounts List Screen (Jetpack Compose)
//
// SCENARIO
// Build the accounts list screen for PNC Mobile Android — the final screen
// for Module 12. This exercise pulls together state (Block 1), navigation
// (Block 3), LazyColumn (Block 4), accessibility (Block 6), and animation
// (Block 7).
//
// REQUIREMENTS
// 1. Build AccountListScreen using LazyColumn and Material 3 components.
// 2. Each row shows account name, masked account number, and balance.
// 3. Tapping a row calls onAccountClick(accountId) — wiring this to actual
//    Navigation Compose is assumed to happen in a NavHost elsewhere (not
//    part of this file).
// 4. Every row must be fully readable by TalkBack as ONE combined element,
//    not three separate announcements.
// 5. Add an AnimatedVisibility confirmation banner that appears briefly
//    after a simulated refresh (a button that toggles a "Refreshed!"
//    message is sufficient to demonstrate this).
//
// The Account model below is complete. Implement the two TODOs.
//

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp


data class Account(
    val id: String,
    val name: String,
    val maskedNumber: String,
    val balance: Double
)

val sampleAccounts = listOf(
    Account("a1", "Everyday Checking", "\u2022\u2022\u2022\u2022 4471", 4281.16),
    Account("a2", "High Yield Savings", "\u2022\u2022\u2022\u2022 9902", 18340.50),
    Account("a3", "Rewards Credit Card", "\u2022\u2022\u2022\u2022 2216", -612.44)
)

// MARK: - TODO 1: AccountListScreen

@Composable
fun AccountListScreen(accounts: List<Account>, onAccountClick: (String) -> Unit) {
    var refreshing by remember { mutableStateOf(false) }

    Column(modifier = Modifier.fillMaxSize()) {
        LazyColumn(modifier = Modifier.weight(1f)) {
            item{ Text("Accounts", style = MaterialTheme.typography.headlineMedium, modifier = Modifier.padding(16.dp)) }
            items(
                items = accounts,
                key = { account -> account.id }
            ) { account ->
                AccountRow(
                    account = account,
                    onClick = { onAccountClick(account.id) }
                )
            }
        }
        AnimatedVisibility(
            visible = refreshing,
            enter   = fadeIn(),
            exit    = fadeOut()
        ) { Text("Refreshed!", modifier = Modifier.padding(16.dp)) }
        Button(
            onClick = { refreshing = true },
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp)
        ) {
            Text("Refresh ")
            Icon(
                painter = painterResource(id = R.drawable.outline_refresh),
                contentDescription = null
            )
        }
    }
}

@Composable
fun AccountRow(account: Account, onClick: () -> Unit) {
    Column(
        verticalArrangement = Arrangement.spacedBy(4.dp),
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 8.dp)
            .border(
                width = 1.dp,
                color = Color.LightGray,
                shape = RoundedCornerShape(12.dp)
            )
            .clickable { onClick() }
            .padding(16.dp)
            .semantics(mergeDescendants = true) {
                contentDescription =
                    "${account.name}, account ending in ${account.maskedNumber.takeLast(4)}, " +
                            "balance ${"%.2f".format(account.balance)} dollars"
            }
    ) {
        Text(
            text = account.name,
            style = MaterialTheme.typography.titleMedium
        )
        Text(
            text = account.maskedNumber,
            style = MaterialTheme.typography.bodyMedium,
            color = Color.Gray
        )
        Text(
            text = "$${"%.2f".format(account.balance)}",
            style = MaterialTheme.typography.bodyLarge
        )
    }
}
