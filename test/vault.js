const Vault = artifacts.require("Vault");
const WETH = artifacts.require("WETH");

contract("Vault", accounts => {
    const [deployer, user] = accounts;

    let vault;
    let weth;

    before(async () => {
        weth = await WETH.new({ from: deployer });
        vault = await Vault.new(weth.address, { from: deployer });
    });

    it("should deposit ETH correctly", async () => {
        const depositAmount = web3.utils.toWei('1', 'ether');

        await vault.depositETH({ from: user, value: depositAmount });

        const balance = await vault._ethBalances(user);
        assert.equal(balance.toString(), depositAmount, "ETH balance is incorrect");
    });

    it("should wrap ETH to WETH correctly", async () => {
        const wrapAmount = web3.utils.toWei('1', 'ether');

        await vault.wrapToWETH(wrapAmount, { from: user });

        const wethBalance = await vault._tokenBalances(weth.address, user);
        assert.equal(wethBalance.toString(), wrapAmount, "WETH balance is incorrect");
    });

    it("should unwrap WETH to ETH correctly", async () => {
        const unwrapAmount = web3.utils.toWei('1', 'ether');

        await vault.unwrapWETH(unwrapAmount, { from: user });

        const wethBalanceAfter = await vault._tokenBalances(weth.address, user);
        const ethBalanceAfter = await vault._ethBalances(user);
        assert.equal(wethBalanceAfter.toString(), '0', "WETH balance should be zero");
        assert.equal(ethBalanceAfter.toString(), web3.utils.toWei('1', 'ether'), "ETH balance should be restored");
    });

    it("should withdraw ETH correctly", async () => {
        const withdrawAmount = web3.utils.toWei('1', 'ether');

        await vault.withdrawETH(withdrawAmount, { from: user });

        const balanceAfter = await vault._ethBalances(user);
        assert.equal(balanceAfter.toString(), '0', "ETH balance should be zero after withdrawal");
    });

    // More tests can be added here for depositToken, withdrawToken, etc.
});
