<style scoped lang="scss">
</style>

<template lang="pug">
  .container
    template(v-if="this.bidding.show_new_button_question")
      router-link.button.button-primary.router-link.mt-2.mb-2.u-full-width(:to="{ name: 'NewLotQuestion', params: { bidding_id: this.biddingId, lot_id: this.lotId } }")
        | {{ $t('.button.new_lot_question') }}

    .card.slim.mb-2.mt-2
      ul.mb-0
        li.list-item.row.p-1(v-for="lot_question in lot_questions", key="lot_question.question")
          .container
            .list-title
              | {{ lot_question.question }}
            span(v-if="lot_question.answer")
              | {{ lot_question.answer }}
            span(v-else)
              | {{ $t('.waiting_answer') }}
</template>

<script>
  export default {
    name: 'lotQuestions',

    data () {
      return {
        i18nScope: 'biddings.lots.lot_questions.index',
        lot_questions: null,
        isLoading: true,
        bidding: {}
      }
    },

    methods: {
      fetch() {
        this.isLoading = true

        return this.$http.get('/supplier/biddings/' + this.biddingId + '/lots/' + this.lotId + '/lot_questions')
          .then((response) => {
            this.lot_questions = response.data
            this.isLoading = false

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
