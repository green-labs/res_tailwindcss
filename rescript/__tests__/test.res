open Jest
open Expect

describe("", _ => {
  test("", _ => {
    let header = View.header
    expect(header) |> toEqual("py-1.5")
  })

  test("content", _ => {
    let header10 = View.header10
    expect(header10) |> toEqual("before:content-['']")
  })

  test("self & children selector", _ => {
    let header11 = View.header11
    expect(header11) |> toEqual("peer-checked:[&>svg]:rotate-180")
  })

  test("descendant combinator", _ => {
    let header12 = View.header12
    expect(header12) |> toEqual("[&_a]:tw-mt-4")
  })
})
