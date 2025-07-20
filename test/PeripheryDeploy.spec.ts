import { expect } from "chai";
import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomicfoundation/hardhat-ethers/signers";
import * as fs from "fs";
import * as path from "path";

describe("Periphery Router Deployment Test", function () {
  let owner: SignerWithAddress;
  let router: any;

  beforeEach(async function () {
    [owner] = await ethers.getSigners();
  });

  it("should deploy UniswapV2Router01 from periphery artifacts", async function () {
    console.log("Deploying UniswapV2Router01 from periphery artifacts...");

    // peripheryフォルダのRouterアーティファクトを読み込み
    const routerArtifactsPath = path.join(__dirname, "../periphery/artifacts/contracts/UniswapV2Router01.sol/UniswapV2Router01.json");
    const routerArtifact = JSON.parse(fs.readFileSync(routerArtifactsPath, "utf8"));

    // アーティファクトからコントラクトファクトリを作成
    const Router = new ethers.ContractFactory(
      routerArtifact.abi,
      routerArtifact.bytecode,
      owner
    );

    // ダミーのアドレスでデプロイ（実際のFactoryとWETHは不要）
    const dummyFactory = "0x0000000000000000000000000000000000000001";
    const dummyWETH = "0x0000000000000000000000000000000000000002";

    router = await Router.deploy(dummyFactory, dummyWETH);
    await router.waitForDeployment();

    const routerAddress = await router.getAddress();
    console.log("✅ UniswapV2Router01 deployed at:", routerAddress);

    // デプロイが成功したことを確認
    expect(routerAddress).to.not.equal(ethers.ZeroAddress);
    expect(await router.factory()).to.equal(dummyFactory);
    expect(await router.WETH()).to.equal(dummyWETH);
  });
}); 