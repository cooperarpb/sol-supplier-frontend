<style scoped lang="scss">
</style>

<template lang="pug">
  .container
    template(v-if="this.bidding.show_new_button_question")
      router-link.button.button-primary.router-link.mt-2.mb-2.u-full-width(:to="{ name: 'NewLotQuestion', params: { bidding_id: this.biddingId, lot_id: this.lotId } }")
        | {{ $t('.button.new_lot_question') }}

    .card.slim.mb-2.mt-2(v-if="this.lotQuestionsCount > 0")
      ul.mb-0
        li.list-item.row.p-1(v-for="lotQuestion in this.lotQuestions", key="lot_question.question")
          .container
            .list-title
              | {{ lotQuestion.question }}
            span(v-if="lotQuestion.answer")
              | {{ lotQuestion.answer }}
            span(v-else)
              | {{ $t('.waiting_answer') }}

    span(v-if="this.lotQuestionsCount == 0")
      | {{ $t('.no_lot_questions') }}

</template>

<script>
  export default {
    name: 'lotQuestions',

    data () {
      return {
        i18nScope: 'biddings.lots.lot_questions.index',
        lotQuestions: null,
        lotQuestionsCount: 0,
        isLoading: true,
        bidding: {},

        tabs: [
          {
            route: { name: 'bidding', params: {} },
            icon: 'fa-file',
            text: this.$t('models.bidding.one'),
            active: true,
          },

          {
            route: { name: 'lots', params: {} },
            icon: 'fa-list',
            text: this.$t('biddings.tabs.lots'),
            active: false,
          }
        ]
      }
    },

    methods: {
      fetch() {
        this.isLoading = true

        return this.$http.get('/supplier/biddings/' + this.biddingId + '/lots/' + this.lotId + '/lot_questions')
          .then((response) => {
            this.lotQuestions = response.data
            this.lotQuestionsCount = this.lotQuestions.length
            this.isLoading = false

            this.updateTabs()
            this.$emit('navbarTitleChanged', this.$t('.title'))

          }).catch((_err) => {
            this.error = _err
            console.error(_err)
          })
      },

      getBidding() {
        return this.$http.get('/supplier/biddings/' + this.biddingId)
          .then((response) => {
            this.bidding = response.data

          }).catch((_err) => {
            this.error = _err
            console.error(_err)
          })
      },


      parseRoute() {
        this.biddingId = this.$params.asInteger(this.$route.params.bidding_id)
        this.lotId = this.$params.asInteger(this.$route.params.lot_id)
      },

      updateTabs() {
        // add resource id to router tab
        this.tabs[0].route.params = { id: this.biddingId }
        this.tabs[1].route.params = { bidding_id: this.biddingId }

        this.$emit('tabChanged', this.tabs)
      },

      init() {
        this.parseRoute()
        this.getBidding()
        this.fetch()
      }      
    },

    created: function () {
      this.init();
    }
  }
</script>
