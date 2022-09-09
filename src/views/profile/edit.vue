<style scoped lang="scss">
  .avatar {
    display: block;
    margin-left: auto;
    margin-right: auto;
    height: 60px;
    width: 60px;
    border-radius: 100%;
    border: solid 1px #dadada;
  }
  .avatar-loading {
    background-color: #dadada;
    i {
      padding: 23px;
    }
  }
  .input-file {
    display: none;
  }

  .icon-button {
    padding: 0 12px;
    height: 28px;

    line-height: 28px;
    margin-right: 10px;
  }

 .errors {
    .error,
    label {
      color: red;
    }

    .error {
      font-size: 12px;
    }
  }

  .terms-container {
    text-align: center;
    line-height: 18px;
  }

</style>

<template lang="pug">
  .root
    .container.mt-2.provider
      template(v-if="provider.id")
        form.card(ref="form", method="patch", @submit.prevent="submit" )

          template(v-if="uploadPercentage > 0 && uploadPercentage < 100")
            .avatar.avatar-loading
              i.fa.fa-spin.fa-spinner
          template(v-else)
            img.avatar(:src="avatarPath", @click="$refs.inputFile.click()")

          input.input-file(type="file", name="provider[suppliers_attributes][avatar]" ref="inputFile", @change="onFileChange($event.target.name, $event.target.files)")

          hr.mt-1.mb-1

          h4.title
            | {{ this.$t('.general.title') }}

          label
            | {{ this.$t('.labels.document') }}
          span {{ this.provider.document }}

          input-field.mt-1(
            :autofocus="true",
            type="text",
            v-model="provider.name",
            name="provider[name]",
            require=true,
            :error="errors.name"
          )

          AddressFields(:errors="errorsAddress" prefix="provider" :address="address" stateSelectIdProp="state-1")

          hr
          h4.title
            | {{ this.$t('.legal_representative.title') }}

          input(type="hidden", name="provider[legal_representative_attributes][id]", :value="legal_representative.id" v-if="provider.legal_representative")

          input-field(
            type="text",
            model="legal_representative",
            v-model="legal_representative.name",
            name="provider[legal_representative_attributes][name]",
            require=true,
            :error="errorsLegalRepresentative['legal_representative.name']"
          )

          input-field(
            type="text",
            model="legal_representative",
            v-model="legal_representative.nationality",
            name="provider[legal_representative_attributes][nationality]",
            require=true,
            :error="errorsLegalRepresentative['legal_representative.nationality']"
          )


          select-field(
            name="provider[legal_representative_attributes][civil_state]",
            model="legal_representative",
            v-model="legal_representative.civil_state",
            :options="civilStates",
            :placeholder="$t('.something')",
            require=true,
            :error="errorsLegalRepresentative['legal_representative.civil_state']"
          )

          input-field(
            type="text",
            model="legal_representative",
            v-model="legal_representative.rg",
            name="provider[legal_representative_attributes][rg]",
            require=true,
            :error="errorsLegalRepresentative['legal_representative.rg']"
          )

          input-field(
            type="text",
            model="legal_representative",
            v-model="legal_representative.cpf",
            name="provider[legal_representative_attributes][cpf]",
            require=true,
            :error="errorsLegalRepresentative['legal_representative.cpf']",
            mask="000.000.000-00",
          )

          input-field(
            type="text",
            model="legal_representative",
            v-model="legal_representative.valid_until",
            name="provider[legal_representative_attributes][valid_until]",
            :error="errorsLegalRepresentative['legal_representative.valid_until']"
          )

          AddressFields(:errors="errorsLegalRepresentativeAddress" prefix="provider[legal_representative_attributes]"  :address="legal_representative_address" errorPrefix="legal_representative."  stateSelectIdProp="state-2")

          hr
          h4.title
            | {{ this.$t('.users.title') }}

          input(type="hidden", name="provider[suppliers_attributes][id]", :value="supplier.id")

          phone-field(
            name="provider[suppliers_attributes][phone]",
            type="text",
            model="supplier",
            v-model="supplier.phone",
            require=true,
            :error="errorsSupplier['suppliers.phone']"
          )

          input-field(
            name="provider[suppliers_attributes][password]",
            type="password",
            model="supplier",
            v-model="supplier.password",
            require=true,
            :error="errorsSupplier['suppliers.password']"
          )

          input-field(
            name="provider[suppliers_attributes][password_confirmation]",
            type="password",
            model="supplier",
            v-model="supplier.password_confirmation",
            require=true,
            :error="errorsSupplier['suppliers.password_confirmation']"
          )

          select-field(
            name="provider[suppliers_attributes][locale]",
            v-model="locale",
            :options="locales",
            :error="errorsSupplier['suppliers.locale']",
            :label="$t('.languages')"
          )

          .mt-2
            button.button-submit.u-full-width(
              type="submit",
              :disabled="submitting"
            )
              | {{ submitText }}

</template>

<script>
  import AddressFields from '../addresses/address-fields.vue';

  export default {
    name: 'EditProvider',

    components: {
      AddressFields
    },

    props: {
      redirect: { type: String }
    },

    data () {
      return {
        i18nScope: 'providers.edit',
        submitting: false,
        finding: false,

        errors: {},
        errorsSupplier: {},
        errorsAddress: {},
        errorsLegalRepresentative: {},
        errorsLegalRepresentativeAddress: {},

        uploadPercentage: null,
        preview: null,

        // form
        provider: null,
        provider_document: '',
        provider_type: null,
        supplier: {},
        address: {},
        legal_representative_address: {},
        legal_representative: {},

        locales: [
          { id: 'es-PY', text: this.$t('profile.edit.locale.spanish') },
          { id: 'en-US', text: this.$t('profile.edit.locale.english') },
          { id: 'pt-BR', text: this.$t('profile.edit.locale.portuguese') },
          { id: 'fr-FR', text: this.$t('profile.edit.locale.french') }
        ],
        locale: app.auth.user.locale
      }
    },

    computed: {
      avatarPath() {
        if(this.preview) return this.preview
        return app.secrets.api.host + this.supplier.avatar.url
      },

      navbarTitle() {
        return this.$t('.title')
      },

      submitText() {
        if (this.submitting) return this.$t('.button.submitting')
        return this.$t('.button.submit')
      },


      civilStates() {
        return [
          { id: 'single', text: this.$t('models.legal_representative.attributes.civil_states.single') },
          { id: 'married', text: this.$t('models.legal_representative.attributes.civil_states.married') },
          { id: 'divorced', text: this.$t('models.legal_representative.attributes.civil_states.divorced') },
          { id: 'widower', text: this.$t('models.legal_representative.attributes.civil_states.widower') },
          { id: 'separated', text: this.$t('models.legal_representative.attributes.civil_states.separated') }
        ]
      },
    },

    methods: {
      getProvider() {
        this.$http.get('/supplier/find_current_provider')
          .then(response => {
            this.provider = response.data
            this.supplier = this.provider.current_supplier || {}
            this.address = this.provider.address || {}
            this.legal_representative = this.provider.legal_representative || {}
            this.legal_representative_address = this.provider.legal_representative.address || {}
          }).catch(error => {
            this.errors = error.data.errors
          })
      },

      catchErrors(err) {
        let errors = _.dig(err, 'response', 'data', 'errors') || {}

        this.$notifications.error(this.$t('.notifications.failure'))

        this.errors = this.$i18n.errify(errors, { model: 'provider' })
        this.errorsAddress = this.$i18n.errify(errors, { model: 'address' })
        this.errorsSupplier = this.$i18n.errify(errors, { model: 'suppliers' })
        this.errorsLegalRepresentative = this.$i18n.errify(errors, { model: 'legal_representative' })
        this.errorsLegalRepresentativeAddress = this.$i18n.errify(errors, { model: 'legal_representative.address' })
      },

      submitSuccess(response) {
        this.errors = {}

        // nesse momento atualizamos o locale
        app.store.set('locale', this.locale)
        app.i18n.locale = this.locale

        this.$notifications.clear()
        this.$notifications.info(this.$t('.notifications.success'))
        this.$router.replace({ name: "home" })
      },

      onFileChange(fieldName, file) {
        let imageFile = file[0]
        let imageURL = URL.createObjectURL(imageFile)
        this.preview = imageURL
      },

      submit() {
        const formData = new FormData(this.$refs.form)
        this.submitting = true

        if(this.provider.id) {
          this.$http.patch('/supplier/profile', formData, {
            onUploadProgress: uploadEvent => {
              this.uploadPercentage = uploadEvent.loaded / uploadEvent.total * 100
              console.log(this.uploadPercentage)
            }
          })
            .then((response) => {
              this.submitSuccess()
            })
            .catch((err) => {
              this.catchErrors(err)
            })
            .then(() => {
              this.submitting = false
            })
        }
      },

      redirecToIndex() {
        let redirectToRoute = { name: 'login' }
        this.$router.replace(redirectToRoute)
      },
    },

    created: function() {
      this.getProvider()
    },
  }

</script>
