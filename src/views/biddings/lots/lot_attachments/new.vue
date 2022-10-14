<style scoped lang="scss">
</style>

<template lang="pug">
  .container
    form(ref="form", method="post", @submit.prevent="confirmSubmit")
      input(type="hidden", name="lot_attachment[lot_id]", :value="this.lotId")

      input.input-file(type="file", name="lot_attachment[attachment_attributes][file]")

      button.button-submit.button-long.u-full-width(
        type="submit",
        :disabled="submitting"
      )
        | {{ submitText }}

</template>

<script>
  export default {
    name: 'newLotAttachment',

    data () {
      return {
        i18nScope: 'biddings.lots.lot_attachments.new',
        errors:  {},
        lot_attachment: {},
        submitting: false,

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

        this.changeTabs()
        this.$emit('navbarTitleChanged', this.$t('.title'))
      },

      confirmSubmit() {
        let message = {
          title: this.$t('.confirm.title'),
          body: this.$t('.confirm.body')
        }

        let options = {
          cancelText: this.$t('.dialog.back'),
          okText: this.$t('.dialog.confirm')
        }

        this.$dialog.confirm(message, options)
          .then((dialog) => {
            this.submit()
          })
          .catch(function (err) {
            console.log(err)
          });
      },

      submit() {
        const formData = new FormData(this.$refs.form)
        this.submitting = true

        this.$http.post('/supplier/biddings/' + this.biddingId + '/lots/' + this.lotId + '/lot_attachments', formData)
          .then((response) => {
            this.$notifications.clear()
            this.errors = {}

            this.$router.replace({ name: 'LotAttachments', params: { bidding_id: this.biddingId, lot_id: this.lotId } })
          })
          .catch((err) => {
            let errors = _.dig(err, 'response', 'data', 'errors') || {}

            this.$notifications.error(this.$t('.notifications.failure'))
            this.errors = this.$i18n.errify(errors, { model: 'lot_attachment' })
          })
          .then(() => {
            this.submitting = false
          })
      },

      changeTabs() {
        // add resource id to router tab
        this.tabs[0].route.params = { id: this.biddingId }
        this.tabs[1].route.params = { bidding_id: this.biddingId }

        this.$emit('tabChanged', this.tabs)
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
