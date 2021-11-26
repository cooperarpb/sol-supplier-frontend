<style scoped lang="scss">
</style>

<template lang="pug">
  .container
    form(ref="form", method="post", @submit.prevent="submit")
      input(type="hidden", name="lot_question[lot_id]", :value="this.lotId")

      textarea-field.mt-2(
        v-model="lot_question.question",
        name="lot_question[question]",
        :label="$t('.form.fields.question_label')",
        :error="errors.question",
        require=true
      )

      button.button-submit.button-long.u-full-width(
        type="submit",
        :disabled="submitting"
      )
        | {{ submitText }}

</template>

<script>
  export default {
    name: 'newLotQuestion',

    data () {
      return {
        i18nScope: 'biddings.lots.lot_questions.new',
        errors:  {},
        lot_question: {},
        submitting: false
      }
    },

    computed: {
      submitText() {
        if (this.submitting) return this.$t('.button.submitting')
        return this.$t('.button.submit')
      }
    },

    methods: {
      parseRoute() {
        this.biddingId = this.$params.asInteger(this.$route.params.bidding_id)
        this.lotId = this.$params.asInteger(this.$route.params.lot_id)
      },

      submit() {
        const formData = new FormData(this.$refs.form)
        this.submitting = true

        this.$http.post('/supplier/biddings/' + this.biddingId + '/lots/' + this.lotId + '/lot_questions', formData)
          .then((response) => {
            this.$notifications.clear()
            this.errors = {}

            this.$router.replace({ name: 'LotQuestions', params: { bidding_id: this.biddingId, lot_id: this.lotId } })
          })
          .catch((err) => {
            let errors = _.dig(err, 'response', 'data', 'errors') || {}

            this.$notifications.error(this.$t('.notifications.failure'))
            this.errors = this.$i18n.errify(errors, { model: 'lot_question' })
          })
          .then(() => {
            this.submitting = false
          })
      },

      init() {
        this.parseRoute()
      }
    },

    created: function () {
      this.init();
    },
  }
</script>
