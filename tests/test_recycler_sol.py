def test_recycle(token, amount, whale, gauge, strategyProxy):
    # Deposit to the vault, whale approves 10% of his stack and deposits it
    token.approve(vault, amount, {"from": whale})
    vault.deposit(amount, {"from": whale})
    assert token.balanceOf(vault) == amount


    # harvest, store asset amount
    strategy.harvest({"from": strategist})
    # tx.call_trace(True)
    old_assets_dai = vault.totalAssets()
    old_proxy_balanceOf_gauge = strategyProxy.balanceOf(gaugeIB)
    old_gauge_balanceOf_voter = gaugeIB.balanceOf(voter)
    old_strategy_balance = token.balanceOf(strategy)
    old_estimated_total_assets = strategy.estimatedTotalAssets()
    old_vault_balance = token.balanceOf(vault)
    assert strategyProxy.balanceOf(gaugeIB) == amount
    assert old_assets_dai == amount
    assert old_assets_dai == strategyProxy.balanceOf(gaugeIB)

    # simulate a month of earnings
    chain.sleep(2592000)
    chain.mine(1)

    # harvest after a month, store new asset amount
    strategy.harvest({"from": strategist})
    # tx.call_trace(True)
    new_assets_dai = vault.totalAssets()
    new_proxy_balanceOf_gauge = strategyProxy.balanceOf(gaugeIB)
    new_gauge_balanceOf_voter = gaugeIB.balanceOf(voter)
    new_strategy_balance = token.balanceOf(strategy)
    new_estimated_total_assets = strategy.estimatedTotalAssets()
    new_vault_balance = token.balanceOf(vault)
    assert old_assets_dai == strategyProxy.balanceOf(gaugeIB)


def test_dai_deposit(token, dai, amount, whale, strategyProxy, gauge)