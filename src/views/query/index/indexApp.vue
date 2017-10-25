<template>
  <div>
    <div class="page-tabbar">
      <div class="page-wrap">
        <mt-tab-container swipeable v-model="selected">
          <mt-tab-container-item id="query">
            <div class="query-main-wrap">
              <h2 class="query-title">合约查询</h2>
              <mt-field class="ui-mt-10" label="钱包地址" placeholder="请输入要查询的钱包地址" type="text" v-model="query.address"></mt-field>
              <div class="grid">
                <mt-button size="large" @click="queryContract" type="primary" class="ui-mt-20" icon="search">查询</mt-button>
              </div>
              <div class="method-introduce ui-mt-20">
                <p>往以下地址打款即得相应智能合约</p>
                <p><b>{{factoryAddr}}</b></p>
              </div>
              <div v-if="showResult" class="query-result-wrap ui-mt-20">
                <div class="query-result-total" v-if="queryResultList.length > 0">
                    <span>共{{queryResultList.length}}条合约</span>
                </div>
                <div v-if="queryResultList.length > 0" class="query-result-item" :key="index" v-for="(ret, index) in queryResultList">
                  <p class="item-title">合约{{index+1}}</p>
                  <dl>
                    <dt>合约地址</dt>
                    <dd>{{ret['2']}}</dd>
                  </dl>
                  <dl>
                    <dt>合约别名</dt>
                    <dd>{{ret['0']}}</dd>
                  </dl>
                  <dl>
                    <dt>购买价格</dt>
                    <dd>{{ret['1']}}</dd>
                  </dl>
                  <dl>
                    <dt><a :href="ret.jumpUrl">合约描述&gt;</a></dt>
                  </dl>
                </div>
                <mt-cell v-else title="合约数量" value="0"></mt-cell>
              </div>
            </div>
          </mt-tab-container-item>
          <mt-tab-container-item id="charge">
            <div class="charge-guide">
              <h4 class="guide__title">充值指引</h4>
              <p class="step-title">第一步：转账到如下工厂地址</p>
              <dl class="step-detail">
                <dd><b v-html="factoryAddr"></b></dd>
              </dl>
              <p class="step-title">第二步：转账成功后使用自己的钱包地址查询生成的合约信息</p>
              <p class="step-title">第三步：通过合约地址和abi到myetherwallet进行合约参数初始化，设置代币名字</p>
            </div>
          </mt-tab-container-item>
          <mt-tab-container-item id="qa">
            <dl class="qa-item">
              <dt class="qa-title">常见问题一</dt>
              <dd>阿斯顿发生</dd>
              <dd>阿斯顿发生</dd>
              <dd>阿斯顿发生</dd>
            </dl>
            <dl class="qa-item">
              <dt class="qa-title">常见问题一</dt>
              <dd>阿斯顿发生</dd>
              <dd>阿斯顿发生</dd>
              <dd>阿斯顿发生</dd>
            </dl>
          </mt-tab-container-item>
        </mt-tab-container>
      </div>
      <mt-tabbar v-model="selected">
        <mt-tab-item id="query">
            <i slot="icon" class="iconfont icon-querycondition"></i>
            查询合约
        </mt-tab-item>
        <mt-tab-item id="charge">
            <i slot="icon" class="iconfont icon-chongzhi"></i>
            充值
        </mt-tab-item>
        <mt-tab-item id="qa">
            <i slot="icon" class="iconfont icon-changjianwenti"></i>
            常见问题
        </mt-tab-item>
      </mt-tabbar>
    </div>
    <div class="loading" v-if="loading">
        <mt-spinner color="#26a2ff" :size="50"  type="triple-bounce"></mt-spinner>
    </div>
  </div>
</template>
<script>
import Web3 from 'web3';
import {abi} from 'assets/js/abi';

function getQuery(name, url) {
  //参数：变量名，url为空则表从当前页面的url中取
  var u = arguments[1] || window.location.search.replace("&amp;", "&"),
      reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)"),
      r = u.substr(u.indexOf("\?") + 1).match(reg);
  return r != null ? r[2] : "";
}
let isTest = getQuery('env') == 'test';

export default {
  data() {
    return {
      selected: 'query',
      web3: '',
      contract: '', // 智能合约对象
      factoryAddr: isTest ? '0x7028f811eeebe2d95f4ae6546c89a369fdf5c2b2' : '',
      loading: false,
      queryResultList: [],
      showResult: false,
      query: {
        address: ''
      }
    }
  },
  created() {
    // 初始化web3对象
    this.web3 = new Web3();
    this.web3.setProvider(new Web3.providers.HttpProvider("https://www.cctoken.com/json-rpc"));
    // 调用智能合约
    this.contract = new this.web3.eth.Contract(abi, this.factoryAddr);
  },
  methods: {
    queryContract() {
      if (this.loading) {
        return;
      }
      if (!this.web3.utils.isAddress(this.query.address)) {
        this.$toast('地址不合法，请重新输入');
        return;
      }
      this.loading = true;
      this.contract.methods.queryUserContractCount(this.query.address).call({ from: this.factoryAddr }, (err, result) => {
        if (err) {
          this.loading = false;
          this.$toast('查询合约遇到错误，请重试');
        } else {
          this.queryResultList = [];
          for (let i = 0; i < result; i++) {
            this.contract.methods.queryUserContract(this.query.address, i).call({ from: this.factoryAddr }, (err, detail) => {
              if (!err) {
                detail.jumpUrl = 'abi_'+detail['1']+'.html';
                let balance = this.web3.utils.fromWei(detail['1'], 'ether');
                detail['1'] = Number(balance).toFixed(4) + 'eth';
                this.queryResultList.push(detail);
                if (i + 1 == result) {
                  this.showResult = true;
                  this.loading = false;
                }
              } else {
                this.$toast('查询合约遇到错误');
              }
            })
          }
        }
      })
    }
  }
}
</script>

<style lang="scss">
body {
  background-color: #f5f5f5;
}

.page-tabbar {
  overflow: hidden;
  height: 100vh;
  -webkit-overflow-scrolling: touch;
}
.page-wrap {
  overflow: auto;
  height: 100%;
  padding-bottom: 100px;
}

.qa-item {
  background-color: #fff;
  margin-top: 10px;
  padding: 20px;
  line-height: 1.6;
  color: #999;
  font-size: 12px;
  .qa-title {
    color: #333;
    font-size: 14px;
  }
  &:first-child {
    margin-top: 0;
  }
}

.query-main-wrap {
  margin-top: 10%;
  .query-title {
    font-size: 24px;
    text-align: center;
    font-weight: normal;
  }
}

.query-result-total {
  height: 1px;
  width: 80%;
  margin: 30px auto 0;
  background-color: #ccc;
  color: #666;
  position: relative;
  text-align: center;
  font-size: 0;
  span {
    display: inline-block;
    padding: 10px;
    background-color: #f5f5f5;
    font-size: 16px;
    transform: translateY(-50%);
  }
}

.grid {
  padding-left: 0.2rem;
  padding-right: 0.2rem;
}

.loading {
  position: absolute;
  left: 50%;
  top: 50%;
  color: #333;
  transform: translate(-50%, -50%);
  font-size: 14px;
  text-align: center;
}

.query-result-wrap {
  padding-bottom: 2rem;
}

.query-result-item {
  background-color: #fff;
  margin-top: 20px;
  dl {
    border-bottom: 1px solid #e5e5e5;
    font-size: 14px;
    color: #666;
    padding: 15px 0.2rem;
    line-height: 1.2;
    dt {
      font-size: 16px;
      color: #333;
      margin-bottom: 5px;
    }
  }
  a {
    color: #369;
    text-decoration: none;
  }
  .item-title {
    text-align: center;
    font-size: 18px;
    padding: 10px 0;
  }
}

.charge-guide {
  padding: 1rem 0.2rem 0.3rem;
  .guide__title {
    font-size: 18px;
  }
  .step-title {
    font-size: 14px;
    color: #333;
    margin-top: 20px;
  }
  .step-detail {
    margin-top: 5px;
    font-size: 14px;
  }
}

.mint-tab-container {
  -webkit-overflow-scrolling: touch;
}

.method-introduce {
  font-size: 14px;
  color: #333;
  line-height: 1.8;
  text-align: center;
}
</style>




