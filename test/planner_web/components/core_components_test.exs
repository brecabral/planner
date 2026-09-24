defmodule PlannerWeb.CoreComponentsTest do
  use ExUnit.Case, async: true

  use Phoenix.Component
  import Phoenix.LiveViewTest
  import PlannerWeb.CoreComponents

  test "text fields preserve values, labels and browser constraints" do
    html =
      render_component(&input/1,
        id: "email",
        name: "profile[email]",
        type: "email",
        label: "Email",
        value: "person@example.com",
        required: true,
        readonly: true
      )
      |> LazyHTML.from_fragment()

    assert text(html, "label[for=email] .label") == "Email"
    assert attribute(html, "#email", "name") == ["profile[email]"]
    assert attribute(html, "#email", "value") == ["person@example.com"]
    assert exists?(html, "input#email[type=email][required][readonly]")
    refute exists?(html, ".input-error")
  end

  test "form fields derive their identity and translate errors after use" do
    form =
      to_form(%{"title" => "ab"},
        as: :entry,
        errors: [title: {"should be at least %{count} character(s)", [count: 3]}]
      )

    html =
      render_component(&input/1, field: form[:title], label: "Title") |> LazyHTML.from_fragment()

    assert exists?(html, "input#entry_title.input-error[name='entry[title]'][value=ab]")
    assert text(html, "p.text-error") == "deve ter pelo menos 3 caracteres"
  end

  test "unused form fields suppress validation errors" do
    form =
      to_form(%{"title" => "", "_unused_title" => ""},
        as: :entry,
        errors: [title: {"can't be blank", []}]
      )

    html = render_component(&input/1, field: form[:title]) |> LazyHTML.from_fragment()

    assert exists?(html, "#entry_title[value='']")
    refute exists?(html, ".input-error")
    refute exists?(html, "p.text-error")
  end

  test "used required fields show singular errors and allow explicit identity overrides" do
    form = to_form(%{"title" => ""}, as: :entry, errors: [title: {"can't be blank", []}])

    html =
      render_component(&input/1,
        field: form[:title],
        id: "custom-title",
        name: "title",
        value: "replacement"
      )
      |> LazyHTML.from_fragment()

    assert exists?(html, "#custom-title[name=title][value=replacement]")
    assert text(html, "p.text-error") == "não pode ficar em branco"
  end

  test "hidden fields carry their value without a visible label" do
    html =
      render_component(&input/1, type: "hidden", id: "token", name: "token", value: "a&b")
      |> LazyHTML.from_fragment()

    assert exists?(html, "input#token[type=hidden][name=token]")
    assert attribute(html, "#token", "value") == ["a&b"]
    refute exists?(html, "label")
  end

  test "checkboxes submit a false fallback and reflect checked and disabled states" do
    html =
      render_component(&input/1,
        type: "checkbox",
        id: "enabled",
        name: "enabled",
        value: "true",
        label: "Enabled",
        disabled: true,
        form: "settings"
      )
      |> LazyHTML.from_fragment()

    assert exists?(
             html,
             "input#enabled[type=checkbox][checked][disabled][value=true][form=settings]"
           )

    assert exists?(html, "input[type=hidden][name=enabled][value=false][disabled][form=settings]")
    assert text(html, "label[for=enabled]") == "Enabled"

    unchecked =
      render_component(&input/1,
        type: "checkbox",
        id: "enabled",
        name: "enabled",
        value: true,
        checked: false,
        errors: ["must be accepted"]
      )
      |> LazyHTML.from_fragment()

    refute exists?(unchecked, "#enabled[checked]")
    refute exists?(unchecked, "input[disabled]")
    assert text(unchecked, "p.text-error") == "must be accepted"
  end

  test "select fields render prompts, options and the selected value" do
    html =
      render_component(&input/1,
        type: "select",
        id: "priority",
        name: "priority",
        label: "Priority",
        prompt: "Choose a priority",
        options: [{"Low", "low"}, {"High", "high"}],
        value: "high",
        errors: ["is unavailable"]
      )
      |> LazyHTML.from_fragment()

    assert text(html, "label[for=priority] .label") == "Priority"
    assert text(html, "option[value='']") == "Choose a priority"
    assert text(html, "option[value=low]") == "Low"
    assert text(html, "option[selected]") == "High"
    assert exists?(html, "select#priority.select-error[name=priority]")
    refute exists?(html, "option[value=low][selected]")
    assert text(html, "p.text-error") == "is unavailable"
  end

  test "multiple selects derive an array parameter and retain all selected values" do
    form = to_form(%{"colors" => ["red", "blue"]}, as: :preferences)

    html =
      render_component(&input/1,
        field: form[:colors],
        type: "select",
        multiple: true,
        options: ["red", "green", "blue"]
      )
      |> LazyHTML.from_fragment()

    assert exists?(html, "select#preferences_colors[multiple][name='preferences[colors][]']")
    assert attribute(html, "option[selected]", "value") == ["red", "blue"]
    refute exists?(html, "option[value='']")
    refute exists?(html, ".select-error")
  end

  test "textareas preserve multiline text and escape user markup" do
    html =
      render_component(&input/1,
        type: "textarea",
        id: "notes",
        name: "notes",
        value: "First line\n<script>alert('test')</script>",
        label: "Notes",
        rows: 4,
        errors: ["is too long"]
      )
      |> LazyHTML.from_fragment()

    assert exists?(html, "textarea#notes.textarea-error[name=notes][rows='4']")
    assert text(html, "label[for=notes] .label") == "Notes"
    assert text(html, "textarea") == "First line\n<script>alert('test')</script>"
    refute exists?(html, "script")
    assert text(html, "p.text-error") == "is too long"
  end

  test "flash messages expose accessible alerts and a dismissal command" do
    html =
      render_component(&flash/1,
        kind: :info,
        flash: %{"info" => "Saved <entry>"},
        title: "Success"
      )
      |> LazyHTML.from_fragment()

    assert exists?(html, "#flash-info[role=alert] .alert-info")
    assert text(html, "p.font-semibold") == "Success"
    assert text(html, "#flash-info") =~ "Saved <entry>"
    refute exists?(html, "entry")
    assert exists?(html, "button[type=button][aria-label=fechar]")
    [command] = attribute(html, "#flash-info", "phx-click")

    assert [
             ["push", %{"event" => "lv:clear-flash", "value" => %{"key" => "info"}}],
             ["hide", %{"to" => "#flash-info"}]
           ] = Jason.decode!(command)
  end

  test "flash slots override stored messages and empty flashes render no alert" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.flash id="failure" kind={:error} flash={%{"error" => "Old message"}}>
        Try again
      </.flash>
      """)
      |> LazyHTML.from_fragment()

    assert exists?(html, "#failure[role=alert] .alert-error")
    assert text(html, "#failure") == "Try again"
    refute exists?(html, "p.font-semibold")

    empty = render_component(&flash/1, kind: :info, flash: %{}) |> LazyHTML.from_fragment()
    refute exists?(empty, "[role=alert]")
  end

  test "buttons render actions or navigation links with their content and attributes" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.button id="save" disabled>Save</.button>
      <.button id="home" navigate="/" variant="primary">Home</.button>
      <.button id="download" href="/report" download class="custom-button">Download</.button>
      """)
      |> LazyHTML.from_fragment()

    assert exists?(html, "button#save[disabled]")
    assert text(html, "#save") == "Save"
    assert exists?(html, "a#home[href='/'][data-phx-link=redirect]")
    assert text(html, "#home") == "Home"
    assert exists?(html, "a#download.custom-button[href='/report'][download]")
    assert text(html, "#download") == "Download"
  end

  test "headers present title, subtitle and action content" do
    assigns = %{}

    html =
      rendered_to_string(~H"""
      <.header>
        Settings
        <:subtitle>Choose your preferences</:subtitle>
        <:actions><button id="reset">Reset</button></:actions>
      </.header>
      """)
      |> LazyHTML.from_fragment()

    assert text(html, "header h1") == "Settings"
    assert text(html, "header p") == "Choose your preferences"
    assert text(html, "header button#reset") == "Reset"
  end

  defp exists?(html, selector), do: html |> LazyHTML.query(selector) |> Enum.any?()

  defp text(html, selector),
    do: html |> LazyHTML.query(selector) |> LazyHTML.text() |> String.trim()

  defp attribute(html, selector, name),
    do: html |> LazyHTML.query(selector) |> LazyHTML.attribute(name)
end
