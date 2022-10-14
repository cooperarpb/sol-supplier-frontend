<style scoped lang="scss">
  .container {
    width: 100%;

    .sent-lot-attachment-message {
      border: 1px solid $brownish-grey;
      display: block;
      padding: 10px;
      text-align: center;
    }
  }
</style>

<template lang="pug">
.container
  template(v-if="lot.allow_lot_attachment_action")
    router-link.button.button-primary.router-link.mt-2.mb-2.u-full-width(:to="{ name: 'NewLotAttachment', params: { bidding_id: this.biddingId, lot_id: this.lotId } }")
      | {{ $t('.button.new_lot_attachment') }}

  .card.slim.mb-2.mt-2(v-if="this.lotAttachmentsCount > 0")
    ul.mb-0
      li.list-item.row.p-1(v-for="lotAttachment in this.lotAttachments")
        .container
          a.input-file.mb-1(:href="attachmentPath(lotAttachment.attachment_file)", target="_blank")
            i.fa.fa-download.mr-1.u-pull-left
            span.attachment-name {{ lotAttachment.attachment_filename }}

          template(v-if="lotAttachment.status === 'pending'")
            .button.button-primary.router-link.mt-2.mb-2.u-full-width(v-if="lot.allow_lot_attachment_action" @click="confirmAttachmentSending(lotAttachment)")
              | {{ $t('.button.sent') }}

            .button.button-danger.router-link.mb-2.u-full-width(@click="confirmAttachmentRemoval(lotAttachment)")
              | {{ $t('.button.remove') }}
          template(v-else)
            span.mt-2.sent-lot-attachment-message {{ $t('.sent_lot_attachment') }}

  span(v-if="this.lotAttachmentsCount == 0")
    | {{ $t('.no_lot_attachments') }}

</template>

<script>
  export default {
    name: 'lotAttachments',

    data () {
      return {
        i18nScope: 'biddings.lots.lot_attachments.index',
        lotAttachments: null,
        lotAttachmentsCount: 0,
        isLoading: true,
        bidding: {},
        lot: {},

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

        return this.$http.get('/supplier/biddings/' + this.biddingId + '/lots/' + this.lotId + '/lot_attachments')
          .then((response) => {
            this.lotAttachments = response.data
            this.lotAttachmentsCount = this.lotAttachments.length
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

      getLot() {
        return this.$http.get('/supplier/biddings/' + this.biddingId + '/lots/' + this.lotId)
          .then((response) => {
            this.lot = response.data

          }).catch((_err) => {
            this.error = _err
            console.error(_err)
          })
      },

      attachmentPath(attachment) {
        if(typeof attachment === 'undefined') return
        return app.secrets.api.host + attachment.url
      },

      confirmAttachmentSending(lotAttachment) {
        let message = {
          title: this.$t('.confirm.sent.title'),
          body: this.$t('.confirm.sent.body')
        }

        let options = {
          cancelText: this.$t('.dialog.sent.back'),
          okText: this.$t('.dialog.sent.confirm')
        }

        this.$dialog.confirm(message, options)
          .then((confirmed) => {
            if(confirmed) {
              this.sendLotAttachment(lotAttachment)
            }
          })
      },

      confirmAttachmentRemoval(lotAttachment) {
        let message = {
          title: this.$t('.confirm.delete.title'),
          body: this.$t('.confirm.delete.body')
        }

        let options = {
          cancelText: this.$t('.dialog.delete.back'),
          okText: this.$t('.dialog.delete.confirm')
        }

        this.$dialog.confirm(message, options)
          .then((confirmed) => {
            if(confirmed) {
              this.deleteLotAttachment(lotAttachment)
            }
          })
      },

      sendLotAttachment(lotAttachment) {
        this.$http.post('/supplier/biddings/' + this.biddingId + '/lots/' + this.lotId + '/lot_attachments/' + lotAttachment.id + '/send_lot_attachment')
          .then((response) => {
            lotAttachment.status = 'sent'
          }).catch((_err) => {
            this.error = _err
            console.error(_err)
          })
      },

      deleteLotAttachment(lotAttachment) {
        this.$http.delete('/supplier/biddings/' + this.biddingId + '/lots/' + this.lotId + '/lot_attachments/' + lotAttachment.id)
          .then((response) => {
            const deletedLotAttachmentIndex = this.lotAttachments.indexOf(lotAttachment)

            if (deletedLotAttachmentIndex > -1) {
              this.lotAttachments.splice(deletedLotAttachmentIndex, 1)
            }
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
        this.getLot()
        this.fetch()
      }      
    },

    created: function () {
      this.init();
    }
  }
</script>
